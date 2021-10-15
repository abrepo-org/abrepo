Rails.application.routes.draw do

  devise_scope :user do

    get "/checkout/account(/:lookup_key)", action: :account, controller: 'checkout',
        as: "checkout_account"

    post "/checkout/account(/:lookup_key)", action: :create, controller: 'checkout',
         as: "checkout_user_create"

  end

  #enable custom 'after_sign_up_path_for'
  devise_for :users, :controllers => {:registrations => "checkout"}

  get 'test_models/test'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'healthcheck', action: :index, controller: 'healthcheck'

  get 'imports', action: :index, controller: 'imports'
  post 'imports', action: :create, controller: 'imports'

  #TODO: nest these routes profiles/<domain>/variations/<slugname> for better SEO
  resources :profiles, only: ['show', 'index']
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
  # "step 2": created user but unsubscribed state
  get '/checkout/subscribe(/:lookup_key)', to: 'stripe#subscribe', as: "checkout_subscribe"
  post '/create-checkout-session/', to: 'stripe#createSession'
  get '/checkout/success/', to: 'stripe#success'
  post '/customer-portal/', to: 'stripe#portal'

  # webhook
  post '/webhooks/stripe_payments', to: 'webhooks#index'

  # default landing page
  root to: "landing#index"

  #legal
  get '/privacy-policy', to: 'legal#privacy'
  get '/terms-of-service', to: 'legal#tos'
  get '/dmca', to: 'legal#dmca'

end
