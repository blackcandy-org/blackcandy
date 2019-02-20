Rails.application.routes.draw do
  root 'home#index'

  resource :session, only: [:new, :create, :destroy]
  resources :songs, only: [:index, :show]
  resources :albums, only: [:index, :show]
  resources :artist, only: [:index, :show]
  resources :users
  resources :stream, only: [:new]
end
