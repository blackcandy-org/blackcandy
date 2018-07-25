Rails.application.routes.draw do
  root 'home#index'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :songs, only: [:index, :new, :show, :create, :destroy]
  resources :users
  resources :stream, only: [:new]
end
