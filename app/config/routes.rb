Rails.application.routes.draw do

  # toggle to send all requests except landing
  # see #landing#index
  get 'healthcheck', action: :index, controller: 'healthcheck'
  get '*path', action: 'maintenance', controller: 'errors'
  #

  # exceptions
  # 500 can't direct to static file since handled by router
  %w( 404 422 500 ).each do |code|
    get code, action: "show", controller: "errors", :code => code
  end

  devise_scope :user do

    get "/users/edit", action: :edit, controller: 'checkout'

    get "/checkout/account/(:lookup_key)", action: 'redirect', controller: 'landing',
        as: "checkout_account"

    post "/checkout/account/(:lookup_key)", action: 'redirect', controller: 'landing',
         as: "checkout_user_create"

    # allow override of after_confirmation_path_for in confirmations controller
    get "/users/confirmation", action: :show, controller: 'confirmations'

  end

  devise_for :users, only: [:sessions, :registrations, only: [:edit]]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'imports', action: :index, controller: 'imports'
  post 'imports', action: :create, controller: 'imports'

  #SEO slugified routes (redirects in controller)
  # variations/:id/<summary_name>
  # profiles/<:id/<company_name>
  get '/profiles/:id/*name', action: :show, controller: 'profiles'
  resources :profiles, only: ['show', 'index']
  get '/variations/:id/*name', action: :show, controller: 'variations'
  resources :variations, only: ['show', 'update']

  resources :experiments, only: ['update']
  resources :tags, only: ['index']
  resources :industries, only: ['index']

  # Home page feed
  get '/home', to: 'home#index'

  post '/saved', to: 'user_saved_variations#create'
  get '/saved', to: 'user_saved_variations#index'

  # Search
  get 'search', action: :index, controller: 'search'

  #
  # Stripe
  #

  # checkout purchase subscription
  # where buttons submit to our server to get a valid stripe session
  post '/create-checkout-session/', action: 'redirect', controller: 'landing'

  # post purchase create a Subscription object if not created
  get '/checkout/success/', action: 'redirect', controller: 'landing'

  # webhook, receives events like subscription
  # post '/webhooks/stripe_payments', to: 'webhooks#index'

  # post '/customer-portal/', to: 'stripe#portal'

  # catch all redirect
  # get '*path', action: 'redirect', controller: 'landing'

  # default landing page
  root to: "landing#index"

  #legal
  get '/privacy-policy', action: 'redirect', controller: 'landing'
  get '/terms-of-service', action: 'redirect', controller: 'landing'
  get '/dmca', action: 'redirect', controller: 'landing'

end
