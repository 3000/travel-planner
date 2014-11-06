module Travels
  module Updaters

    class TripUpdater
      attr_accessor :trip, :params, :user

      def initialize(trip, params, user = nil)
        self.trip = trip
        self.params = params
        self.user = user
      end

      def new_trip
        new_trip = Travels::Trip.new
        copy_attributes(new_trip) unless trip.blank?
        new_trip
      end

      def create_trip
        new_trip = Travels::Trip.new(params)
        new_trip.author_user_id = user.id
        new_trip.users = [user]
        new_trip.save
        unless trip.blank?
          new_trip.days.each_with_index do |day, index|
            original_day = (trip.days || [])[index]
            next if original_day.blank?
            day.attributes = original_day.attributes_for_clone.merge(date_when: day.date_when)
          end
          new_trip.save # duplicate save - try to avoid
        end
        new_trip
      end

      def process_days
        params.each do |_, day_hash|
          day = trip.days.where(id: day_hash[:id]).first
          next if day.blank?

          unless day_hash[:hotel].blank?
            hotel_hash = day_hash[:hotel]
            day.hotel.update_attributes(name: hotel_hash[:name], price: hotel_hash[:price],
              comment: hotel_hash[:comment])
            process_nested(day.hotel.links, day_hash[:hotel][:links] || [])
          end

          day.update_attributes(comment: day_hash[:comment], add_price: day_hash[:add_price])

          process_nested(day.places, day_hash[:places] || [])

          process_ordered(day_hash[:transfers] || [])
          process_nested(day.transfers, day_hash[:transfers] || [])

          activities_params = prepare_activities_params(day_hash[:activities] || [])
          process_ordered(activities_params)
          process_nested(day.activities, activities_params)

          process_nested(day.expenses, day_hash[:expenses] || [])

          day.save
        end
      end

      def process_trip
        trip.update_attributes(comment: params[:comment])
        trip
      end

      private

      def prepare_activities_params act_params
        act_params.delete_if{|hash| hash[:name].blank?} || []
      end

      # TODO permit only some params - possible security problem
      def process_nested(collection, params)
        to_delete = []
        collection.each do |item|
          to_delete << item.id if params.select{|v| v[:id] == item.id.to_s}.count == 0
        end
        collection.where(:id.in => to_delete).destroy
        params.each do |item_hash|
          item = collection.where(id: item_hash.delete(:id)).first
          # TODO remove - only for client side
          item_hash.delete(:isCollapsed)
          if item.blank?
            collection.create(item_hash)
          else
            item.update_attributes(item_hash)
          end
        end
      end

      def process_ordered(params)
        params.each_with_index do |item_hash, index|
          item_hash['order_index'] = index
        end
      end

      def copy_attributes new_trip
        new_trip.copy(trip) unless trip.blank?
      end

    end

  end
end