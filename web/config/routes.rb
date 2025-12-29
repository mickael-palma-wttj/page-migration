Rails.application.routes.draw do
  # Dashboard
  root "dashboard#index"

  # Company search (live database)
  resources :organizations, only: [:index, :show] do
    collection do
      get :search
    end
  end

  # Command execution
  resources :commands, only: [:index, :new, :create, :show, :destroy] do
    member do
      post :interrupt
    end
  end

  # Export browser
  resources :exports, only: [:index, :show] do
    member do
      get "file/*path", action: :file, as: :file, format: false
    end
  end

  # Side-by-side comparison
  resources :comparisons, only: [:index, :show]

  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check
end
