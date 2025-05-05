Rails.application.routes.draw do
  get "messages/index"
  get "messages/show"
  get "messages/create"
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Suppression des routes automatiques pour MediaItems et MediaFolders
  delete "media_items/create"
  delete "media_items/destroy"
  delete "media_folders/create"
  delete "media_folders/destroy"

  resources :listings do
    resources :media_items, only: [:create, :destroy]
    resources :media_folders, only: [:create, :destroy]
    resources :messages, only: [:create, :index]
  end
  
  resources :media_items, only: [:destroy]
  resources :media_folders, only: [:destroy]
  
  resources :vehicles, only: [:index, :show] do
    collection do
      get 'categories'
      get 'subcategories/:category_id', to: 'vehicles#subcategories', as: 'subcategories'
      get 'vehicle_types'
      get 'specific_fields'
      get 'equipment_categories'
    end
  end
  
  resources :categories
  
  resources :messages, only: [:index, :create]
  get 'conversations/:user_id', to: 'messages#show', as: 'conversation'

  # Dashboard routes
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/my_listings', to: 'dashboard#my_listings'
  get 'dashboard/my_purchases', to: 'dashboard#my_purchases'
  get 'dashboard/wallet', to: 'dashboard#wallet'
  get 'dashboard/messages', to: 'dashboard#messages'
  get 'dashboard/transport', to: 'dashboard#transport'
  get 'dashboard/services', to: 'dashboard#services'
  get 'dashboard/profile', to: 'dashboard#profile'
  
  # Payment routes
  post 'payments/create_checkout', to: 'payments#create_checkout'
  post 'payments/create_crypto_charge', to: 'payments#create_crypto_charge'
  post 'webhooks/stripe', to: 'payments#stripe_webhook'
  post 'webhooks/coinbase', to: 'payments#coinbase_webhook'

  # Defines the root path route ("/")
  root "pages#home"
  
  get 'my_listings', to: 'listings#my_listings'

  # Routes pour l'administration
  namespace :admin do
    root to: 'dashboard#index'
    resources :users
    resources :listings
    resources :vehicles
    resources :categories
  end
end
