class CheckoutController < Devise::RegistrationsController

  # require_no_authentication: if signed in, redirects to root/etc, don't visit new/create
  # allows us to avoid re-creating users if user exist
  # for /initial we have our own redirect to checkout_review_path (vs root)
  prepend_before_action :require_no_authentication, only: [:create]

  #sets a controller variable @minimum_password_length
  prepend_before_action :set_minimum_password_length, only: [:initial]

  include CheckoutHelper
  protect_from_forgery with: :exception, :except => [:createSession]

  #
  # need a separate action to avoid prepend_before_action hooks so we
  # can actually execute custom controller / hook code like redirects
  # this is basically a prepended Devise::RegistrationsController#new
  #
  def initial

    if user_signed_in?
      redirect_to checkout_review_path( params_price_key )
      return
    end

    #registration#new
    build_resource
    yield resource if block_given?
    respond_with resource
  end

  #
  # devise: registrations#create
  # modified last line to render checkout view on error (defaults to :new)
  #
  def create

    build_resource(sign_up_params)
    resource.save

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      #respond_with resource
      render :initial
    end
  end

  #
  # STRIPE RELATED
  #
  # pricing page, inital step
  #
  def review

    unless user_signed_in?
      redirect_to checkout_initial_path(params_price_key)
      return
    end

    #
    # if already have subscription, send to manage accounts
    #
    if current_user.subscribed?
      redirect_to edit_user_registration_path
      return
    end


    price_key = params_price_key

    prices = Stripe::Price.list({ lookup_keys:["basic_monthly"] })
    @price = prices[:data][0]

    render :review
  end

  def cancel
    render :cancel
  end

  def success
    @session_id = params[:session_id]

    #TODO: possible redirect to create user / edit password
    #@session = Stripe::Checkout::Session.retrieve(session_id)
    #current_user.stripe_customer_id = @session["customer"]

    render :success
  end


  def createSession

    priceId = params[:data][:priceId]

    # See https://stripe.com/docs/api/checkout/sessions/create
    # for additional parameters to pass.
    # {CHECKOUT_SESSION_ID} is a string literal; do not change it!
    # the actual Session ID is returned in the query parameter when your customer
    # is redirected to the success page.
    begin

      puts "customer", get_stripe_customer_id()
      puts "email: ", get_customer_email()

      session = Stripe::Checkout::Session.create(

        #existing stripe customer
        #NB: given customer_id, user can change email address (primary_key is customer_id)
        #and it will update stripe user info
        customer: get_stripe_customer_id,

        # not yet striped, but registered or nil if not registered
        # NB: customer vs customer_email are exclusive
        # customer_email is locked on checkout (no customer_id yet)
        customer_email: get_customer_email,

        client_reference_id: user_signed_in? ? current_user.id : nil,

        #metadata: {key:value}, #attach to checkout.session object (returned on webhook)
        #data attached to subscription.metadata
        subscription_data: {
          metadata: {
            abrepo_email: user_signed_in? ? current_user.email : nil,
            user_id: user_signed_in? ? current_user.id : nil
          }

          #trial_period_days: 7
        },

        #NB: urls need to be full url not relative
        success_url: 'http://localhost/checkout/success?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: 'http://localhost/checkout/canceled',

        payment_method_types: ['card'],
        mode: 'subscription',
        allow_promotion_codes: true,
        line_items: [
          {
            quantity: 1, #change when volume price_id specified
            price: priceId,
          }
        ],
      )

      render status: 200, json: { sessionId: session.id }

    rescue => e
      render status: 400, json: { 'error': { message: e.error.message } }
    end
  end


  #
  # Customer Portal URL
  #
  def portal

    return_url = 'http://localhost/users/edit/'

    customer_id = current_user.subscriptions.last.stripe_customer_id
    session = Stripe::BillingPortal::Session.create(
      {
        customer: customer_id,
        return_url: return_url
      })

    render status: 200, json: { url: session.url }
  end



  #
  # DEVISE OVERRIDES
  #
  # /users/sign_up - redirect when not signed up
  #
  def new
    redirect_to checkout_initial_path( params_price_key )
  end

  #
  # https://github.com/heartcombo/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-in,-sign-up,-or-sign-out
  #
  #
  def after_sign_up_path_for(resource)
    return checkout_review_path(params[:price_key]) unless params[:price_key].blank?
    root_path
  end

end
