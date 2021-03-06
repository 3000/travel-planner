describe Travels::Trip do

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:end_date) }
  it { should validate_presence_of(:author_user_id) }

  it_should_behave_like 'a model with date interval', :trip, :start_date, :end_date

  it 'does not allow trips 30 days long' do
    trip = FactoryGirl.build(:trip, start_date: Date.today, end_date: Date.today + 30.days)
    expect(trip).not_to be_valid
  end

  it 'does not allow trips longer than 30 days' do
    trip = FactoryGirl.build(:trip, start_date: Date.today, end_date: Date.today + 35.days)
    expect(trip).not_to be_valid
  end

  describe '.where' do
    before(:context) {FactoryGirl.create_list(:trip, 12, author_user_id: 'user_test_travels_trip')}

    context 'when there are several trips' do

      it 'paginates per 9 items by default' do
        trips = Travels::Trip.all.page(1).to_a
        expect(trips.count).to eq(9)
      end

      context 'and when one deleted trip' do
        let!(:deleted_trip) { FactoryGirl.create :trip, author_user_id: 'user_test_travels_trip', archived: true }

        it 'returns only not deleted trips by default' do
          expect(Travels::Trip.unscoped.where(id: deleted_trip.id, archived: true).first).not_to be_blank
          trips = Travels::Trip.where(author_user_id: 'user_test_travels_trip').to_a
          expect(trips.count).to eq(12)
        end
      end
    end
  end

  describe '#update_plan' do
    let(:trip){FactoryGirl.create(:trip, :with_filled_days)}

    it 'creates trip days on save' do
      expect(trip.days.count).to eq(8)
      expect(trip.days.first.date_when).to eq(trip.start_date)
      expect(trip.days.last.date_when).to eq(trip.end_date)
    end

    it 'recounts dates on update preserving other data' do
      trip.update_attributes(start_date: 14.days.ago, end_date: 7.days.ago)
      updated_trip = trip.reload

      expect(updated_trip.days.count).to eq(8)
      expect(updated_trip.days.first.date_when).to eq(14.days.ago.to_date)
      expect(updated_trip.days.last.date_when).to eq(7.days.ago.to_date)

      updated_trip.days.each_with_index do |day, index|
        expect(day.comment).to eq("Day #{index}")
      end
    end

    it 'creates new days when necessary' do
      trip.update_attributes(start_date: 16.days.ago, end_date: 7.days.ago)
      updated_trip = trip.reload

      expect(updated_trip.days.count).to eq(10)
      expect(updated_trip.days.first.date_when).to eq(16.days.ago.to_date)
      expect(updated_trip.days.last.date_when).to eq(7.days.ago.to_date)
      expect(updated_trip.days.last.comment).to be_nil
    end

    it 'deletes days when necessary' do
      trip.update_attributes(start_date: 12.days.ago, end_date: 7.days.ago)
      updated_trip = trip.reload

      expect(updated_trip.days.count).to eq(6)
      expect(updated_trip.days.first.date_when).to eq(12.days.ago.to_date)
      expect(updated_trip.days.last.date_when).to eq(7.days.ago.to_date)
      expect(updated_trip.days.last.comment).to eq("Day 5")
    end
  end

  describe '#include_user' do
    let(:trip){FactoryGirl.create(:trip, :with_users)}
    let(:user){FactoryGirl.create(:user)}

    it 'includes some user' do
      expect(trip.include_user(trip.author)).to be true
    end

    it 'does not include new user' do
      expect(trip.include_user(user)).to be false
    end
  end

  describe '#last_non_empty_day_index' do
    let(:trip_empty){FactoryGirl.create(:trip)}
    let(:trip_full){FactoryGirl.create(:trip, :with_filled_days)}

    it 'returns -1 if all days are empty' do
      expect(trip_empty.last_non_empty_day_index).to eq(-1)
    end

    it 'returns last day index if all days are non-empty' do
      expect(trip_full.last_non_empty_day_index).to eq(7)
    end

    it 'returns last non-empty day index' do
      trip_empty.days[0].comment = 'comment'
      trip_empty.days[0].save
      trip_empty.days[3].comment = 'comment'
      trip_empty.days[3].save
      expect(trip_empty.last_non_empty_day_index).to eq(3)
    end
  end

  describe '#budget_sum' do
    context 'when empty trip' do
      let(:trip) {FactoryGirl.create(:trip)}

      it 'returns zero' do
        expect(trip.budget_sum).to eq(0)
      end
    end

    context 'when filled trip' do
      let(:trip) {FactoryGirl.create(:trip, :with_filled_days)}

      it 'returns right budget' do
        hotel_price = trip.days.inject(0) { |sum, day| sum += day.hotel.price }
        days_add_price = trip.days.inject(0) { |sum, day| sum += day.expenses.inject(0) {|i_s, ex| i_s += (ex.price || 0) } }
        transfers_price = trip.days.inject(0) { |s, day| s += day.transfers.inject(0) { |i_s, tr| i_s += tr.price} }
        activities_price = trip.days.inject(0) { |s, day| s += day.activities.inject(0) { |i_s, ac| i_s += ac.price} }

        expect(trip.budget_sum).to eq([hotel_price, days_add_price, transfers_price, activities_price].reduce(&:+))
      end
    end
  end

  describe '#name_for_file' do
    context 'for normal trip' do
      let(:trip) {FactoryGirl.create(:trip, name: 'simple')}

      it 'returns name' do
        expect(trip.name_for_file).to eq trip.name
      end
    end
    context 'for trip name with slash and spaces' do
      let(:trip) {FactoryGirl.create(:trip, name: 'trip with spaces/slash_underscore')}

      it 'returns safe name' do
        expect(trip.name_for_file).to eq 'trip_with_spaces_slash_underscore'
      end
    end
    context 'for russian trip name' do
      let(:trip) {FactoryGirl.create(:trip, name: 'Дубай на майские')}

      it 'returns safe name' do
        expect(trip.name_for_file).to eq 'Дубай_на_майские'
      end
    end
    context 'for long trip name' do
      let(:trip) {FactoryGirl.create(:trip,
        name: 'very very very very very very very very very very very very very very very very very very very very long name')}

      it 'returns safe name' do
        expect(trip.name_for_file).to eq 'very_very_very_very_very_very_very_very_very_very_'
      end
    end
  end

  describe '#as_json' do
    let(:trip) {FactoryGirl.create(:trip, :with_filled_days)}
    let(:trip_json) {trip.as_json}

    it 'has string id field' do
      expect(trip_json['id']).not_to be_blank
      expect(trip_json['id']).to be_a String
      expect(trip_json['id']).to eq(trip.id.to_s)
    end

    it 'has all attributes' do
      expect(trip_json['name']).to eq(trip.name)
      expect(trip_json['comment']).to eq(trip.comment)
      expect(trip_json['short_description']).to eq(trip.short_description)
      expect(trip_json['start_date']).to eq(trip.start_date)
      expect(trip_json['end_date']).to eq(trip.end_date)
      expect(trip_json['private']).to eq(trip.private)
      expect(trip_json['archived']).to eq(trip.archived)
      expect(trip_json['budget_for']).to eq(trip.budget_for)
    end

  end

  describe '#days_count' do
    context 'when a week trip' do
      let(:trip) {FactoryGirl.create(:trip, :with_filled_days)}

      it 'returns 8 days' do
        expect(trip.days_count).to eq 8
      end
    end

    context 'when a minimal trip' do
      let(:trip) {FactoryGirl.create(:trip, start_date: Date.today, end_date: Date.today + 1)}

      it 'returns 2 days' do
        expect(trip.days_count).to eq 2
      end
    end
  end

end