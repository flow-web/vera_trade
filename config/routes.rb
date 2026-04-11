Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  resources :listing_wizards, only: [:new, :create, :edit, :update] do
    member do
      patch :publish
      patch :save_step
    end
  end

  # M8 — create/update retirés, remplacés par ListingWizardsController.
  resources :listings, only: [:index, :show, :new, :edit, :destroy] do
    resource :favorite, only: [:create, :destroy]
  end

  resources :vehicles, only: [] do
    collection { get :fetch_info }
  end

  resources :messages, only: [:index, :create]
  get "conversations/:user_id", to: "messages#show", as: "conversation"

  resources :car_brands, only: [] do
    collection { get :search }
  end

  resources :wallet_transactions, path: "transactions", only: [:index, :show]
  resources :search_presets, only: [:index, :create, :show, :update, :destroy]

  get "my_listings", to: "listings#my_listings"
  get "favorites", to: "favorites#index"
  get "dashboard", to: "dashboard#index", as: :dashboard

  # SEO sitemap
  get "sitemap.xml", to: "pages#sitemap", defaults: { format: :xml }

  # PWA
  get "manifest.webmanifest", to: "pwa#manifest"
  get "service-worker.js", to: "pwa#service_worker"
  get "offline", to: "pwa#offline"
end
