Rails.application.routes.draw do
  root 'home#index'

  resource :session, only: [:new, :create, :destroy]
  resources :artists, only: [:index, :show]
  resources :users
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

    collection do
      get 'init'
    end
  end
end
