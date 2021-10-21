class StripeController < ApplicationController
  include CheckoutHelper

  def subscribe

    #
    # if no account, must register account
    #
    unless user_signed_in?
      redirect_to checkout_account_path(params_lookup_key)
      return
    end

    #
    # if already have subscription, send to home
    #
    if current_user.subscribed?
      redirect_to home_path
      return
    end

    @price_key = params_lookup_key
    @price = get_stripe_data(@price_key)

    out = "Loading: #{@price['lookup_key']}: #{@price.id}, #{@price.nickname}"
    puts "\e[#{31}m#{out}\e[0m"

  end


  def success
    # successful purchase sends user to checkout#success and also
    # triggers webhook; this endpoint exists because there's a race
    # webhook can be delayed,but we want to immediately enabled the
    # user's subscription
    #
    # Since it's async when webhook actually hits our backend to
    # create a subscription, we create subscription from either
    # checkout#success or webhook. Typically webhook will have already
    # done this
    #
    # see checkout_helper:purchase_stripe
    #   sets success_url: checkout/success (this endpoint)
    #   sets cancel_url: checkout/subscribe

    @session_id = params[:session_id]
    if @session_id.nil?
      redirect_to checkout_subscribe_path
      return
    end

    begin
      session = Stripe::Checkout::Session.retrieve(@session_id)

      subscription = Subscription.where(
        user_id: session.client_reference_id,
        stripe_customer_id: session['customer'],
        stripe_subscription_id: session['subscription']
      ).first_or_create.update(
        active: session['payment_status'] == "paid",
        billing_issue: session['payment_status'] != "paid"
      );

    rescue => e

      out = "Stripe Session Error: #{e}"
      puts "\e[#{31}m#{out}\e[0m"

    end

    flash[:notice] = "Your subscription is enabled. Thank you!."
    redirect_to home_path

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
  # "Manage Account" sends POST request, which we relay to Stripe
  # to get a secure redirect URL for user
  #
  def portal

    # needs to be a full URL
    return_url = [
      ENV['APPLICATION_HOST'],
      edit_user_registration_path
    ].join

    customer_id = current_user.subscriptions.last.stripe_customer_id
    session = Stripe::BillingPortal::Session.create(
      {
        customer: customer_id,
        return_url: return_url
      })

    render status: 200, json: { url: session.url }
  end

end
