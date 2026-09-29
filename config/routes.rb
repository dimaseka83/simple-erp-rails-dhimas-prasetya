Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "locale/:locale", to: "locales#update", as: :set_locale, constraints: { locale: /en|id/ }
  resource :settings, only: %i[ edit update ]

  resources :categories, only: %i[ index create update ]
  resources :products do
    resources :stock_movements, only: :create
  end
  resources :stock_movements, only: :index

  resources :suppliers, only: %i[ index create update ]
  resources :purchase_orders, only: %i[ index show new create edit update ] do
    member do
      patch :mark_as_ordered
      patch :mark_as_received
    end
  end

  resources :customers, only: %i[ index create update ]
  resources :sales_orders, only: %i[ index show new create edit update ] do
    member do
      patch :confirm
      get :invoice
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"
end
