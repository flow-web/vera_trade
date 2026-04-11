Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  resources :listing_wizards, only: [ :new, :create, :edit, :update ] do
    member do
      patch :publish
      patch :save_step
    end
  end

  # M8 — create/update retirés, remplacés par ListingWizardsController.
  resources :listings, only: [ :index, :show, :new, :edit, :destroy ] do
    resource :favorite, only: [ :create, :destroy ]
    # PR2 feat/listing-qa — Q&A publiques BaT-style.
    # Les questions sont postées par tout acheteur connecté (pas le vendeur).
    # Les réponses sont postées uniquement par le vendeur, sur la question.
    resources :listing_questions, only: [ :create ], path: "questions" do
      resource :listing_answer, only: [ :create ], path: "answer"
    end

    # PR3 feat/buyer-contact — modal "Contacter le vendeur / Faire une offre".
    # new → renders the Turbo Frame modal, create → find_or_create_for
    # the (listing, buyer) conversation + appends the first message.
    resource :listing_contact,
             only: [ :new, :create ],
             controller: "listing_contacts",
             path: "contact"
  end

  resources :vehicles, only: [] do
    collection { get :fetch_info }
  end

  resources :messages, only: [ :index, :create ]
  get "conversations/:user_id", to: "messages#show", as: "conversation"

  resources :car_brands, only: [] do
    collection { get :search }
  end

  resources :wallet_transactions, path: "transactions", only: [ :index, :show ]
  resources :search_presets, only: [ :index, :create, :show, :update, :destroy ]

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
