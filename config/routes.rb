Rails.application.routes.draw do
  root 'home#index'

  resource :session, only: [:new, :create, :destroy]
  resource :setting, only: [:show, :update]
  resource :current_playlist, only: [:show, :create]
  resource :favorite_playlist, only: [:show]

  resources :artists, only: [:index, :show]
  resources :stream, only: [:new]
  resources :songs, only: [:index, :show]
  resources :albums, only: [:index, :show]

  resources :users, except: [:show] do
    resource :settings, only: [:update]
  end

  resources :playlists, except: [:new, :edit] do
    resource :song, only: [:create, :destroy], module: 'playlists'
  end

  namespace :dialog do
    resources :playlists, only: [:index]
  end

  get '/403', to: 'errors#forbidden', as: :forbidden
  get '/404', to: 'errors#not_found', as: :not_found
  get '/422', to: 'errors#unprocessable_entity', as: :unprocessable_entity
  get '/500', to: 'errors#internal_server_error', as: :internal_server_error
end
