Rails.application.routes.draw do
  # Help and documentation routes
  get "help", to: "help#index"
  get "help/dispute_guidelines", to: "help#dispute_guidelines"
  get "help/support_faq", to: "help#support_faq"
  
  get "map/index"
  get "map/search", to: "map#search"
  post "map/geocode", to: "map#geocode_address"
  
  # Route alternative pour la carte
  get "carte", to: "map#index", as: "carte"
  devise_for :users
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Main application routes
  resources :listings
  resources :vehicles do
    collection do
      get 'fetch_info'
    end
  end
  
  # Enhanced messaging routes
  resources :messages, only: [:index, :create] do
    member do
      patch :mark_as_read
      post :add_reaction
      delete :remove_reaction
    end
    collection do
      get :templates
      post :archive_conversation
      post :unarchive_conversation
    end
  end
  
  resources :conversations, only: [:show] do
    resources :messages, only: [:create]
    resources :video_calls, only: [:create]
  end
  
  # Video calls routes
  resources :video_calls, only: [:index, :show, :update, :destroy] do
    member do
      get :join
      post :leave
    end
  end
  
  # Message templates
  resources :message_templates, only: [:index, :create, :update, :destroy]

  # Calendar events
  resources :calendar_events do
    collection do
      get :events_data
    end
  end

  # Favorites
  resources :favorites, only: [:index, :create, :destroy]

  # Notifications
  resources :notifications, only: [:index, :update] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end

  # User profiles
  resources :user_profiles, path: 'profiles'

  resources :car_brands, only: [] do
    collection do
      get :search
    end
  end

  # Wallet transactions
  resources :wallet_transactions, path: 'transactions', only: [:index, :show]

  # Routes pour les presets de recherche
  resources :search_presets, only: [:index, :create, :show, :update, :destroy]

  # Services routes
  resources :services, only: [:index, :show] do
    collection do
      get :search
      get :map_data
    end
  end

  resources :service_providers do
    member do
      get :dashboard
    end
    resources :service_offers, except: [:index]
    resources :service_reviews, only: [:create, :update, :destroy]
  end

  resources :service_requests do
    member do
      post :respond
    end
    collection do
      get :my_requests
    end
  end

  resources :service_bookings, only: [:index, :show, :create, :update, :destroy] do
    member do
      patch :accept
      patch :complete
      patch :cancel
    end
  end

  # Disputes and Support System Routes
  resources :disputes do
    member do
      patch :escalate
      patch :resolve
      patch :reopen
    end
    resources :dispute_messages, only: [:create, :destroy]
    resources :dispute_evidences, only: [:create, :show, :destroy] do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :dispute_resolutions, only: [:create, :show, :update, :destroy] do
      member do
        patch :accept
        patch :reject
        patch :implement
      end
    end
  end

  resources :support_tickets, path: 'support' do
    member do
      patch :close
      patch :reopen
      post :rate
    end
    resources :ticket_messages, only: [:create, :destroy]
  end

  # Dashboard routes
  get '/dashboard', to: 'dashboard#index'
  get '/dashboard/analytics', to: 'dashboard#analytics'
  get '/dashboard/calendar', to: 'dashboard#calendar'
  get '/dashboard/notifications', to: 'dashboard#notifications'
  get '/dashboard/favorites', to: 'dashboard#favorites'
  get '/dashboard/services', to: 'service_providers#dashboard'
  get '/dashboard/disputes', to: 'disputes#index'
  get '/dashboard/support', to: 'support_tickets#index'

  # Test route for login debugging
  get '/test_login', to: 'application#test_login'
  post '/test_direct_login', to: 'application#test_direct_login'

  # Other routes
  root "pages#home"
  get 'my_listings', to: 'listings#my_listings'
end
