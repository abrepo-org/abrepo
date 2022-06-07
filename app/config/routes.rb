Rails.application.routes.draw do

  # toggle to send all requests except landing
  # see #landing#index
  # get '*path', action: 'maintenance', controller: 'errors'
  #

  # exceptions
  # 500 can't direct to static file since handled by router
  %w( 404 422 500 ).each do |code|
    get code, action: "show", controller: "errors", :code => code
  end

  devise_scope :user do

    get "/checkout/account/(:lookup_key)", action: :account, controller: 'checkout',
        as: "checkout_account"

    post "/checkout/account/(:lookup_key)", action: :create, controller: 'checkout',
         as: "checkout_user_create"

  end

  #enable custom 'after_sign_up_path_for'
  devise_for :users, :controllers => {:registrations => "checkout"}

  get 'test_models/test'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'healthcheck', action: :index, controller: 'healthcheck'

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
  post '/create-checkout-session/', to: 'stripe#createSession'

  # post purchase create a Subscription object if not created
  get '/checkout/success/', to: 'stripe#success'

  # webhook, receives events like subscription
  post '/webhooks/stripe_payments', to: 'webhooks#index'

  post '/customer-portal/', to: 'stripe#portal'

  # default landing page
  root to: "landing#index"

  #legal
  get '/privacy-policy', to: 'legal#privacy'
  get '/terms-of-service', to: 'legal#tos'
  get '/dmca', to: 'legal#dmca'

end
