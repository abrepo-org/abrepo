class CheckoutController < ApplicationController
  protect_from_forgery :except => [:createSession, :portal]

  #pricing page, inital step
  def index
    prices = Stripe::Price.list({ lookup_keys:["basic_monthly"] })
    @price = prices[:data][0]

    render :index
  end

  def cancel
    render :cancel
  end

  def success
    session_id = params[:session_id]

    #TODO:
    #1. update customer_id in app
    #2. Add customer meta to stripe
    # best done in a webhook?
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
      session = Stripe::Checkout::Session.create(
        success_url: 'http://localhost/checkout/success?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: 'http://localhost/checkout/canceled',
        payment_method_types: ['card'],
        mode: 'subscription',
        allow_promotion_codes: true,
        line_items: [{
                       quantity: 1,
                       price: priceId,
                     }],
      )

      render status: 200, json: { sessionId: session.id }

    rescue => e
      render status: 400, json: { 'error': { message: e.error.message } }
    end
  end

end
