Rails.application.routes.draw do
  # Autenticação
  resource  :session
  resource  :registration, only: [:new, :create]
  resources :passwords, param: :token
  get "confirm_registration", to: "registrations#confirm"

  # Recursos principais
  root "home#index"

  resources :banks
  resources :tipsters
  resources :transactions

  resources :books do
    member { get :transactions }
  end

  resources :bets do
    member { get :inline_edit }
  end

  resources :daily_balances, only: [:index, :edit, :update] do
    collection do
      post :add_for_date
      get  :edit_by_date
      patch :update_by_date
    end
  end

  # Páginas estáticas
  get "pages/about"
  get "pages/authentication"
  get "pages/account"

  # Sistema
  get "up" => "rails/health#show", as: :rails_health_check

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
