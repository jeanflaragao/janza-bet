Rails.application.routes.draw do
  resources :banks
  resources :tipsters

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  get 'confirm_registration', to: 'registrations#confirm'
  resource :registration, only: [:new,:create]
  resource :session
  resources :passwords, param: :token
  get "pages/about"
  get "pages/authentification"
  get "pages/account"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  resources :books do
    resources :transactions, only: [:index, :new, :create]
  end

  resources :bets do
    member do
      get :inline_edit
    end
  end
  
  resources :transactions
  resources :daily_balances, only: [:index, :edit, :update] do
    collection do
      post :add_for_date
      get :edit_by_date
      patch :update_by_date
    end
  end
  
  resources :banks
  
end
