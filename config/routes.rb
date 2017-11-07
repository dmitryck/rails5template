Rails.application.routes.draw do
  devise_for :users

  # root page
  root 'pages#index'

  # static pages
  match '/about',   to: 'pages#about',   via: 'get'
  match '/welcome', to: 'pages#welcome', via: 'get'
end
