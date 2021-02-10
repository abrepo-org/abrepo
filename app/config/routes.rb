Rails.application.routes.draw do

  devise_scope :user do

    get "/checkout/initial(/:price_key)", action: :initial, controller: 'checkout',
        as: "checkout_initial"

    post "/checkout/initial(/:price_key)", action: :create, controller: 'checkout'

  end

  #enable custom 'after_sign_up_path_for'
  devise_for :users, :controllers => {:registrations => "checkout"}

  get 'test_models/test'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'healthcheck', action: :index, controller: 'healthcheck'

  post 'imports/test', action: :test, controller: 'imports'
  post 'imports', action: :create, controller: 'imports'

  #TODO: nest these routes profiles/<domain>/variations/<slugname> for better SEO
  resources :profiles, only: ['show', 'index']
  resources :variations, only: ['show']

  #
  # Stripe
  #
  # checkout purchase subscription

  get '/checkout/review(/:price_key)', to: 'stripe#review', as: "checkout_review"
  post '/create-checkout-session/', to: 'stripe#createSession'
  get '/checkout/success/', to: 'stripe#success'
  get '/checkout/canceled/', to: 'stripe#cancel'
  post '/customer-portal/', to: 'stripe#portal'

  # webhook
  post '/webhooks/stripe_payments', to: 'webhooks#index'

  #default page
  root to: "rails/welcome#index"
end
