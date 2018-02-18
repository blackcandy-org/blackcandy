Rails.application.routes.draw do
  resource  :session, controller: 'clearance/sessions', only: [:create]

  resources :users, controller: 'clearance/users', only: [:create] do
    resource :password,
      controller: 'clearance/passwords',
      only: [:create, :edit, :update]
  end

  get '/sign_in' => 'clearance/sessions#new'
  post '/sign_in' => 'clearance/sessions#create'

  get '/sign_up' => 'clearance/users#new'
  post '/sign_up' => 'clearance/users#create'

  get '/reset_password' => 'clearance/passwords#new'
  post '/reset_password' => 'clearance/passwords#create'

  delete '/sign_out' => 'clearance/sessions#destroy', as: 'sign_out'

  root 'home#index'
end
