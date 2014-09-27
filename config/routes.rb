Travel::Application.routes.draw do

  scope '(:locale)', locale: /ru|en/ do
    devise_for :users, controllers: { registrations: 'registrations' }

    resources :users, only: [:show, :edit, :update]
    resources :trips do
      member do
        post :upload_photo
      end
    end

    namespace :api do
      resources :cities, only: [:index]
      resources :trips, only: [:show, :update] do
        resources :days, only: [:index, :create, :show, :update]
      end
    end
  end

  root to: 'dashboard#index'

end
