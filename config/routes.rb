Rails.application.routes.draw do
  use_doorkeeper
  filter :locale,    :exclude => /^\/admin/
  use_doorkeeper

  # config/routes.rb
  scope '(:locale)', locale: /en|vn/ do
    get 'home/index'
    get 'home/show'
    devise_for :users, controllers: {
        registrations: 'users/registrations',
        sessions: 'users/sessions'
    }
  end

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :users, only: [:show, :update, :destroy, :index, :create]
      resources :categories, only: [:index, :show, :update, :destroy, :create]
      resources :medicines, only: [:index, :show, :update, :destroy, :create]
      resources :inventory_items, only: [:index, :show, :update]
      resources :transactions, only: [:index, :show, :update, :destroy, :create]
      resources :receipts, only: [:index, :create, :show, :update]
      resources :configurations, only: [:show]
      resources :med_batches, only: [:index]
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_scope :user do
    authenticated :user do
      get '/:locale' => 'home#show'
      root 'home#show', as: :authenticated_root
    end
    unauthenticated do
      get '/:locale' => 'home#index'
      root 'home#index', as: :unauthenticated
    end
  end
end
