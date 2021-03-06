describe UsersController do

  let(:attrs) {FactoryGirl.build(:user, :with_home_town).attributes}

  describe '#show' do
    context 'when user is logged in' do
      login_user

      context 'where there is user and his trips' do
        before {FactoryGirl.create_list(:trip, 5, users: [subject.current_user])}

        it 'renders show template with trips' do
          get 'show', id: subject.current_user.id
          user = assigns(:user)
          expect(user).to eq subject.current_user
          trips = assigns(:trips)
          expect(trips.count).to eq 5
          trips.each do |trip|
            expect(trip.include_user(user)).to be true
          end
          expect(response).to render_template 'users/show'
        end
      end

      context 'when there is no user' do
        it 'heads 404' do
          get 'show', id: 'no user'
          expect(response).to have_http_status 404
        end
      end
    end

    context 'when no logged user' do
      let(:user) {FactoryGirl.create(:user)}
      context 'where there is user and his trips' do
        before {FactoryGirl.create_list(:trip, 5, users: [user])}

        it 'renders show template with trips' do
          get 'show', id: user.id
          user_assigned = assigns(:user)
          expect(user_assigned).to eq user
          trips = assigns(:trips)
          expect(trips.count).to eq 5
          trips.each do |trip|
            expect(trip.include_user(user)).to be true
          end
        end
      end
    end
  end

  describe '#edit' do
    context 'when user is logged in' do
      login_user

      context 'and when there is user' do
        it 'renders edit template' do
          get 'edit', id: subject.current_user.id
          expect(response).to render_template 'users/edit'
        end
      end

      context 'and when user wants to edit someone other than himself' do
        let(:new_user) {FactoryGirl.create(:user)}
        it 'redirects to dashboard with error' do
          get 'edit', id: new_user.id
          expect(response).to redirect_to '/'
          expect(flash[:error]).to eq I18n.t('errors.unathorized')
        end
      end

      context 'and when there is no user' do
        it 'heads 404' do
          get 'edit', id: 'no user'
          expect(response).to have_http_status 404
        end
      end
    end

    context 'when no logged user' do
      let(:new_user) {FactoryGirl.create(:user)}
      it 'redirects to sign in' do
        get 'edit', id: new_user.id
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#update' do
    let(:update_attrs) {{ user: attrs.merge(home_town_text: 'new home town text', email: 'new email!!!')}}
    let(:update_attrs_invalid) {{ user: attrs.merge(home_town_code: nil, email: 'new email!!!')}}

    context 'when user is logged in' do
      login_user

      context 'and when there is existing user' do

        context 'and when update params are valid' do
          it 'updates user and redirects to edit' do
            put 'update', update_attrs.merge(id: subject.current_user.id)
            expect(response).to redirect_to edit_user_path(subject.current_user, locale: subject.current_user.locale)
            user = assigns(:user)
            expect(user.home_town_text).to eq 'new home town text'
            expect(user.home_town_code).to eq update_attrs[:user]['home_town_code']
            expect(user.email).to eq subject.current_user.email
          end
        end

        context 'and when update params are not valid' do
          it 'renders edit view with errors' do
            put 'update', update_attrs_invalid.merge(id: subject.current_user.id)

            expect(response).to render_template 'users/edit'
            expect(assigns(:user).errors).not_to be_blank
          end
        end

        context 'and when trying to update other user' do
          let(:new_user) {FactoryGirl.create(:user)}

          it 'redirects to dashboard with error' do
            put 'update', update_attrs.merge(id: new_user.id)
            expect(response).to redirect_to '/'
            expect(flash[:error]).to eq I18n.t('errors.unathorized')
          end
        end

      end

      context 'and when there is no user' do
        it 'heads 404' do
          put 'update', update_attrs.merge(id: 'no_user_id')
          expect(response).to have_http_status 404
        end
      end
    end

    context 'when no logged user' do
      let(:new_user) {FactoryGirl.create(:user)}
      it 'redirects to sign in' do
        put 'update', update_attrs.merge(id: new_user.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#upload_photo' do
    login_user

    let(:file) {fixture_file_upload("#{::Rails.root}/spec/fixtures/files/cat.jpg", 'image/jpeg')}

    it 'uploads trip photo' do
      post 'upload_photo', id: subject.current_user.id, user: {image: file}, w: 10, h: 10, x: 10, y: 10, format: :js
      expect(response).to be_success
      expect(assigns(:user).image).not_to be_blank
    end
  end


end