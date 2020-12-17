Rails.application.routes.draw do
  concern :playable do
    member do
      post 'play'
    end
  end

  root 'home#index'

  resource :session, only: [:new, :create, :destroy]
  resource :setting, only: [:show, :update]

  resources :artists, only: [:index, :show, :edit, :update]
  resources :stream, only: [:new]
  resources :transcoded_stream, only: [:new]
  resources :songs, only: [:index, :show]
  resources :albums, only: [:index, :show, :edit, :update], concerns: :playable
  resources :users, except: [:show]

  resources :playlists, except: [:show, :new, :edit] do
    resource :songs, only: [:show, :create, :destroy, :update], module: 'playlists', concerns: :playable
  end

  namespace :current_playlist do
    resource :songs, only: [:show, :create, :destroy, :update]
  end

  namespace :favorite_playlist do
    resource :songs, only: [:show, :create, :destroy, :update]
  end

  namespace :dialog do
    resources :playlists, only: [:index]
  end

  get '/403', to: 'errors#forbidden', as: :forbidden
  get '/404', to: 'errors#not_found', as: :not_found
  get '/422', to: 'errors#unprocessable_entity', as: :unprocessable_entity
  get '/500', to: 'errors#internal_server_error', as: :internal_server_error
end
