Rails.application.routes.draw do
  filter :locale,    :exclude => /^\/admin/

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
      resources :receipts, only: [:index, :create]
      resources :configurations, only: [:show]
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

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
