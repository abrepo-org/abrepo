class StripeController < ApplicationController
  include CheckoutHelper
  protect_from_forgery with: :exception, :except => [:createSession]

  def subscribe

    unless user_signed_in?
      redirect_to checkout_account_path(params_lookup_key)
      return
    end

    #
    # if already have subscription, send to manage accounts
    #
    if current_user.subscribed?
      redirect_to edit_user_registration_path
      return
    end

    @price_key = params_lookup_key
    @price = get_stripe_data(@price_key)

    out = "Loading: #{@price['lookup_key']}: #{@price.id}, #{@price.nickname}"
    puts "\e[#{31}m#{out}\e[0m"
  end


  def success
    # webhook creates actual subscription object; async, client-side
    # unreliable (could close browser before hitting this route, etc.)
    # TODO: but we do need some kind of temp toggle
    # could query sessionId just for this page?

    @session_id = params[:session_id]

    #TODO: possible redirect to create user / edit password
    #@session = Stripe::Checkout::Session.retrieve(session_id)
    #current_user.stripe_customer_id = @session["customer"]

    render :success
  end


  #
  # "step 2": created user but unsubscribed state
  #
  def createSession

    @price_key = params_price_key
    @price = get_stripe_data(@price_key)
    session = nil

    begin
      session = purchase_stripe(@price.id, @price_key)
    rescue => e
      message = "Payment provider error. Please try again."
      render status: 400, json: { user: {ok: true, errors: false},
                                  stripe: { ok: false, errors: { messages: [ message ] } }}
      return
    end


    render status: 200, json: { user: { ok: true, errors: false },
                                stripe: { ok: true, errors: false, sessionId: session.id }}
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
