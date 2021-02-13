module CheckoutHelper

  def purchase_stripe(price_id, price_key)

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
      cancel_url: "http://localhost/checkout/subscribe/#{price_key}",

      payment_method_types: ['card'],
      mode: 'subscription',
      allow_promotion_codes: true,
      line_items: [
        {
          quantity: 1, #change when volume price_id specified
          price: price_id,
        }
      ],
    )

    return session

  end


  def get_stripe_data(price_key)
    # TODO: cache
    # NB: assume prices respects lookup_keys order, but not entirely sure.
    prices = Stripe::Price.list({ lookup_keys:[price_key, ENV['STRIPE_DEFAULT_LOOKUP_KEY']] })

    price = prices[:data].first

    return price
  end

  #GET initial request (#new) -> lookup_key
  def params_lookup_key
    params[:lookup_key] || ENV['STRIPE_DEFAULT_LOOKUP_KEY']
  end

  #POST requests (#create) -> price_key
  def params_price_key
    params[:data][:price_key] || ENV['STRIPE_DEFAULT_LOOKUP_KEY']
  end

  def get_stripe_customer_id()
    user_signed_in? && !current_user.subscriptions.empty? ?
      current_user.subscriptions.last.stripe_customer_id : nil
  end

  def get_customer_email()
    get_stripe_customer_id().nil? && user_signed_in? ?
      current_user.email : nil
  end
end
