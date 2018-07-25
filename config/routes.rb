Rails.application.routes.draw do
  root 'home#index'

  resource :session, only: [:new, :create, :destroy]
  resources :songs, only: [:index, :new, :show, :create, :destroy]
  resources :users
  resources :stream, only: [:new]
end
