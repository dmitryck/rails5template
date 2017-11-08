# Rails 5 Template

## prerequisites
```ruby
gem install mailcatcher
gem install guard-livereload
brew install graphviz # for the ERD graphs
gem update
bundle exec guard init livereload
```

## getting started
Start new app with:
rails new <yourappname> --skip-bundle

Modify config/environments/development.rb for guard livereloading
```ruby
# inject reloads if any view files change - development only
config.middleware.insert_before Rack::Lock, Rack::LiveReload
```

Modify environments/development.rb for mailcatcher:
```ruby
# environments/development.rb
-----------------------------
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }
```

Start mailcatcher with ```mailcatcher```

Open a tab at http://localhost:1080/ to see emails your app sends - and you can send mail via smtp://localhost:1025

### setup Gemfile

```ruby
gem 'bulma-rails'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'font-awesome-rails'
gem 'jbuilder', '~> 2.5'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.4'
gem 'rails_admin'
gem 'sass-rails', '~> 5.0'
gem 'sqlite3'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'annotate'
  gem 'awesome_print', require: 'ap'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'guard', require: false
  gem 'guard-livereload', require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rack-livereload'
  gem 'rails-erd'
  gem 'rb-fsevent', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :deployment do
  gem 'pg'
end
```

### smoketest
```bundle install
bundle exec guard
rails s
```

### add basic pages
```ruby
rails g controller pages index welcome about
```

test guard and live reload by loading the root page at localhost:3000/pages/index

Now add @import "bulma"; to app/assets/stylesheets/application.scss and save - it should automatically reload

Add Bulma extensions to aplication.SCSS
https://github.com/GiantRavens/bulma_extensions/blob/master/styles.css

### fix up routes in config/routes.rb
```ruby
Rails.application.routes.draw do
  # root page
  root 'pages#index'

  # static pages
  match '/about',   to: 'pages#about',   via: 'get'
  match '/welcome', to: 'pages#welcome', via: 'get'
end
```

Test that localhost:3000/, localhost:3000/welcome etc. all work correctly

### add an appname and helper

```ruby
config/application.rb
-----------------------
# Application Name Definition - called with Rails.application.appname or via Pages Helper Method
def appname
  @appname = "Rails Template Application Name"
end
```

```ruby
helpers/pages_helper.rb
-------------------------
App Name Helper
Pull the application name set in config/application.rb
Call with appname in page layouts like <%= appname %>
def appname
  @appname = Rails.application.appname
end
```

Restart the server - add <%= appname %> to app/views/pages/index.html.erb and reload to see if the appname helper is working.


### Improve page layout and dynamic title and description meta tags

Application Layout at app/views/layouts/application.html.erb:

```ruby
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><% if content_for?(:page_title) %><%= appname %> | <%= yield(:page_title) %><% else %><%= appname %><% end %></title>
    <%= csrf_meta_tags %>
    <% if content_for?(:page_description) %><meta name="description" content="<%= yield(:page_description) %>"/><% end %>
    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= yield %>
  </body>

</html>
```

Example page layout:

```ruby
<%= content_for :page_title, 'Home Page' %>
<%= content_for :page_description, 'Home Page' %>

<%= render 'layouts/navbar' %>

<section class="hero is-link">
  <div class="hero-body">
    <div class="container">
      <div class="columns is-vcentered">
        <div class="column">
          <h1 class="title is-size-1">Welcome Page</h1>
          <h3 class="subtitle is-size-3">Welcome Page for <%= appname %></h3>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="section">
  <div class="container">
    <div class="columns">
      <div class="column">

        <p class="title is-size-3">Pages#welcome</p>
        <p class="subtitle is-size-5">Find me in app/views/pages/welcome.html.erb</p>
        <p>I'm just body text.</p>

      </div>
    </div>
  </div>
</section>

<%= render 'layouts/footer' %>
```

Navbar partial:

```ruby
<nav class="navbar" role="navigation" aria-label="main navigation">
  <div class="navbar-brand">
    <a class="navbar-item has-text-weight-bold" href="<%= root_path %>"><%= appname %></a>
    <button class="button navbar-burger is-borderless" data-target="navMenu"><span></span><span></span><span></span></button>
  </div>
  <div id="navMenu" class="navbar-menu">
    <div class="navbar-start">
      <a class="navbar-item" href="<%= about_path %>">About</a>
      <a class="navbar-item" href="<%= welcome_path %>">Welcome</a>
    </div>
    <div class="navbar-end">
    </div>
  </div>
</nav>
```

Footer partial:
```ruby
<footer class="footer">
  <div class="container">
    <div class="columns">
      <div class="column is-centered">
        <%= appname %>  &copy; 2017
      </div>
    </div>
  </div>
</footer>
```

### build user model

```ruby
rails g model user firstname:string lastname:string isadmin:boolean
```
Modify the boolean attributes in the migration in db/migrate/...

```ruby
t.boolean  :isadmin, null: false, default: false
```

### add authentication with devise

```ruby
rails g devise:install
```

Add devise and mailcatcher configuration options to development.rb:
```ruby
# Devise wants default_url_options set to something - set to actual host in production.rb
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

# Using the mailcatcher gem for local emails during development (especially for devise account emails)
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }
```

Generate Devise for User model:
```ruby
rails g devise User
```

Adjust the user.rb model for the Devise options you want (and uncomment everything except timespamps section of generated migration file):
```ruby
class User < ApplicationRecord
  devise :confirmable, :database_authenticatable, :lockable, :recoverable, :registerable, :timeoutable, :trackable, :validatable
  # not used: :rememberable, :omniauthable
end
```

Run the migration:
```ruby
rails db:migrate
```

Add authentication to the welcome page in pages_controller.rb:
```ruby
before_action :authenticate_user!, except: %i[index about]
```

Now browsing to home (index), and about should render normally - but the welcome (post-signin) page should redirect you to the devise login.

Add a few users like u:test@test.org p:testtest and test login, confirming emails via mailcatcher, etc.

Add signup and signin links to the navbar partial:

```ruby
<nav class="navbar" role="navigation" aria-label="main navigation">
  <div class="navbar-brand">
    <a class="navbar-item has-text-weight-bold" href="<%= root_path %>"><%= appname %></a>
    <button class="button navbar-burger is-borderless" data-target="navMenu"><span></span><span></span><span></span></button>
  </div>
  <div id="navMenu" class="navbar-menu">
    <div class="navbar-start">
      <%= link_to 'About', about_path, class: "navbar-item" %>
      <% if user_signed_in? %><%= link_to 'Welcome', welcome_path, class: "navbar-item" %><% end %>
    </div>

    <div class="navbar-end">
      <% if user_signed_in? %>
        <%= link_to 'Edit Your Account', edit_user_registration_path, class: "navbar-item" %>
        <%= link_to 'Sign Out', destroy_user_session_path, method: 'delete', class: "navbar-item" %>
      <% else %>
        <%= link_to 'Sign Up', new_user_registration_path, class: "navbar-item" %>
        <%= link_to 'Sign In', new_user_session_path, { :class => "navbar-item" } %>
      <% end %>
    </div>
  </div>
</nav>
```

Clean up the devise routes so that you can omit the 'user' path:
# cleaner Devise routes
devise_scope :user do
  get '/signin',  to: 'devise/sessions#new'
  get '/signout', to: 'devise/sessions#destroy'
  get '/signup',  to: 'devise/registrations#new'
  get '/iforgot', to: 'devise/passwords#new'
  get '/resend',  to: 'devise/confirmations#new'
  get '/unlock',  to: 'devise/unlocks#new'
end

Fix up the signin and signout redirects:
```ruby
# application_controller.rb
# override the devise signin and signout url behavior
def after_sign_in_path_for(resource_or_scope)
  welcome_url
end

def after_sign_out_path_for(resource_or_scope)
  root_url
end
```

Integrate Devise Flash Messaging into CSS:

xxx

Generate devise views:

```ruby
rails g devise:views
```

Style the Devise views:

Add an admin flag to one of your users:

Fire up and test the Admin backend:
