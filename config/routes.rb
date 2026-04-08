Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :listings
  resources :vehicles do
    collection do
      get 'fetch_info'
    end
  end
  
  resources :messages, only: [:index, :create]
  get 'conversations/:user_id', to: 'messages#show', as: 'conversation'

  resources :car_brands, only: [] do
    collection do
      get :search
    end
  end

  # Wallet transactions
  resources :wallet_transactions, path: 'transactions', only: [:index, :show]

  # Routes pour les presets de recherche
  resources :search_presets, only: [:index, :create, :show, :update, :destroy]

  # Defines the root path route ("/")
  root "pages#home"
  
  get 'my_listings', to: 'listings#my_listings'

  # Dashboard
  get 'dashboard', to: 'dashboard#index', as: :dashboard
end
