Rails.application.routes.draw do
  get "messages/index"
  get "messages/show"
  get "messages/create"
  devise_for :users
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
  
  resources :messages, only: [:index, :create]
  get 'conversations/:user_id', to: 'messages#show', as: 'conversation'

  # Defines the root path route ("/")
  root "pages#home"
  
  get 'my_listings', to: 'listings#my_listings'
end
