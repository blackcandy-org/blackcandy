Rails.application.routes.draw do
  root "home#index"

  resources :sessions, only: [:new, :create, :destroy]
  resource :setting, only: [:show, :update]
  resource :library, only: [:show]

  resources :artists, only: [:index, :show, :update]
  resources :songs, only: [:index]
  resources :albums, only: [:index, :show, :update] do
    post "play", on: :member
  end

  resources :users, except: [:show] do
    resource :setting, only: [:update], module: "users"
  end

  resources :playlists, only: [:index, :create, :update, :destroy] do
    resource :songs, only: :destroy, action: :destroy_all, module: "playlists"
    resources :songs, only: [:index, :create, :destroy], module: "playlists" do
      post "play", on: :collection
      put "move", on: :member
    end
  end

  namespace :current_playlist do
    resource :songs, only: :destroy, action: :destroy_all
    resources :songs, only: [:index, :create, :destroy] do
      put "move", on: :member
    end
  end

  namespace :favorite_playlist do
    resource :songs, only: :destroy, action: :destroy_all
    resources :songs, only: [:index, :create, :destroy] do
      post "play", on: :collection
      put "move", on: :member
    end
  end

  namespace :dialog do
    resources :playlists, only: [:index, :new, :edit]
    resources :artists, only: [:edit]
    resources :albums, only: [:edit]
  end

  get "/search", to: "search#index", as: "search"

  namespace :search do
    resources :artists, only: [:index]
    resources :songs, only: [:index]
    resources :albums, only: [:index]
    resources :playlists, only: [:index]
  end

  namespace :albums do
    namespace :filter do
      resources :genres, only: [:index]
      resources :years, only: [:index]
    end
  end

  namespace :songs do
    namespace :filter do
      resources :genres, only: [:index]
      resources :years, only: [:index]
    end
  end

  resources :stream, only: [:new]
  resources :transcoded_stream, only: [:new]

  get "/403", to: "errors#forbidden", as: :forbidden
  get "/404", to: "errors#not_found", as: :not_found
  get "/422", to: "errors#unprocessable_entity", as: :unprocessable_entity
  get "/500", to: "errors#internal_server_error", as: :internal_server_error

  get "up", to: "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource :authentication, only: [:create, :destroy]
      resource :system, only: [:show]
      resources :songs, only: [:show]
      resources :stream, only: [:new]
      resources :transcoded_stream, only: [:new]

      namespace :current_playlist do
        resource :songs, only: :destroy, action: :destroy_all
        resources :songs, only: [:index, :destroy, :create] do
          put "move", on: :member
        end
      end

      namespace :favorite_playlist do
        resources :songs, only: [:create, :destroy]
      end
    end
  end
end
