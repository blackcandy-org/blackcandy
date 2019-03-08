Rails.application.routes.draw do
  root 'home#index'

  resource :session, only: [:new, :create, :destroy]
  resources :songs, only: [:index, :show] do
    member do
      post 'favorite'
    end
  end
  resources :albums, only: [:index, :show]
  resources :artist, only: [:index, :show]
  resources :users
  resources :stream, only: [:new]
  resources :song_collections
  resources :playlist, only: [:show, :update, :destroy], constraints: { id: /(current|favorite|\d)/ }
end
