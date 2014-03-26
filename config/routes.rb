Travel::Application.routes.draw do

  scope '(:locale)', locale: /ru|en/ do
    devise_for :users
  end

  root to: 'dashboard#index'
  get '/:locale' => 'dashboard#index'

end
