Hoipolloi::Application.routes.draw do
  resources :conversations do
    post 'read', on: :collection, as: 'read'
    post 'reply', on: :member, as: 'reply'
  end

  # Omniauth
  get '/auth/twitter/callback', to: 'sessions#create'
  delete '/auth/logout', to: 'sessions#destroy'

  post '/rape', to: 'rapes#create', as: 'rape'

  # Root route
  root 'home#index'
end
