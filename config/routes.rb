Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :listings, only: [:index, :show]
  resources :filters, only: [:index]
  resources :search_areas, only: [:index, :update, :destroy] do
    member do
      post :clone
    end
  end
  get "current_search_area" => "current_search_area#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root "index#index"

  if defined? Debugbar
    mount Debugbar::Engine => Debugbar.config.prefix
  end
  mount MissionControl::Jobs::Engine, at: "/jobs"
end
