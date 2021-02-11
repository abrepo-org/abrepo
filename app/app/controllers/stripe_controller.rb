class StripeController < ApplicationController
  include CheckoutHelper
  protect_from_forgery with: :exception, :except => [:createSession]

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

    #
    # TODO: set lookup_keys and name
    #
    prices = Stripe::Price.list({ lookup_keys:["basic_monthly"] })

    @price_key = params_price_key #sets default if no params
    @price = prices[:data][0]

    render :review
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
    priceKey = params[:data][:priceKey]

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
        cancel_url: "http://localhost/checkout/review/#{priceKey}",

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

end
