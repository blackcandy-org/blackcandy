Rails.application.routes.draw do
  root 'home#index'

  resource :session, only: [:new, :create, :destroy]
  resource :setting, only: [:show, :update]
  resources :artists, only: [:index, :show]
  resources :users, except: [:show]
  resources :stream, only: [:new]
  resources :song_collections, except: [:new, :edit]

  resources :albums, only: [:index, :show] do
    member do
      post 'play'
    end
  end

  resources :songs, only: [:index, :show] do
    member do
      post 'favorite'
      get 'add'
    end
  end

  resources :playlist, only: [:show, :update, :destroy], constraints: { id: /(current|favorite|\d+)/ } do
    member do
      post 'play'
    end
  end

  get '/403', to: 'errors#forbidden', as: :forbidden
  get '/404', to: 'errors#not_found', as: :not_found
  get '/422', to: 'errors#unprocessable_entity', as: :unprocessable_entity
  get '/500', to: 'errors#internal_server_error', as: :internal_server_error
end
