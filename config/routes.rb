Rails.application.routes.draw do
  root 'home#index'

  resource :session, only: [:new, :create, :destroy]
  resource :setting, only: [:show, :update]

  resources :artists, only: [:index, :show]
  resources :stream, only: [:new]
  resources :transcoded_stream, only: [:new]
  resources :songs, only: [:index, :show]
  resources :albums, only: [:index, :show]

  resources :users, except: [:show] do
    resource :settings, only: [:update]
  end

  resources :playlists, except: [:show, :new, :edit] do
    resource :songs, only: [:show, :create, :destroy], module: 'playlists'
  end

  namespace :current_playlist do
    resource :songs, only: [:show, :update, :create, :destroy]
  end

  namespace :favorite_playlist do
    resource :songs, only: [:show, :create, :destroy]
  end

  namespace :dialog do
    resources :playlists, only: [:index]
  end

  get '/403', to: 'errors#forbidden', as: :forbidden
  get '/404', to: 'errors#not_found', as: :not_found
  get '/422', to: 'errors#unprocessable_entity', as: :unprocessable_entity
  get '/500', to: 'errors#internal_server_error', as: :internal_server_error
end
