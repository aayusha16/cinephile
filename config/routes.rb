Rails.application.routes.draw do
  get "test", to: "test#index"
  get "movies/search", to: "movies#search", as: :movies_search

resources :movies, only: [ :show ] do
  resources :reviews, only: [ :create ]
end

  resource :session, only: [ :new, :create, :destroy ]

  resources :users, only: [ :new, :create ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
