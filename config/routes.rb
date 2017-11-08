Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users

  # cleaner Devise routes
  devise_scope :user do
    get '/signin',  to: 'devise/sessions#new'
    get '/signout', to: 'devise/sessions#destroy'
    get '/signup',  to: 'devise/registrations#new'
    get '/iforgot', to: 'devise/passwords#new'
    get '/resend',  to: 'devise/confirmations#new'
    get '/unlock',  to: 'devise/unlocks#new'
  end

  # static pages
  get '/about',   to: 'pages#about'
  get '/welcome', to: 'pages#welcome'

  # root page
  root 'pages#index'
end
