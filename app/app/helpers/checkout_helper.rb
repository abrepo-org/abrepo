module CheckoutHelper

  def purchase_stripe(price_id, price_key)

    Rails.logger.info("customer: #{get_stripe_customer_id()}")
    Rails.logger.info("email: #{get_customer_email()}")

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
      success_url: "#{stripe_redirect_host}/checkout/success?session_id={CHECKOUT_SESSION_ID}",

      #stripe back button, no purchase
      cancel_url:  "#{stripe_redirect_host}/#pricing",

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

  # used in landing#index
  def get_all_stripe_data
    lookup_keys = ['basic-monthly', 'basic-annual']

    prices = Rails.cache.fetch("#{lookup_keys}/get_all_stripe_data", expires_in: 1.hours) do
      Stripe::Price.list({ lookup_keys: lookup_keys })
    end

    basic_monthly = prices[:data].find{ |price| price['lookup_key'] == 'basic-monthly' }
    basic_annual = prices[:data].find{ |price| price['lookup_key'] == 'basic-annual' }

    return basic_monthly, basic_annual
  end

  # used in checkout, stripe controllers
  # NB: Price.list does not return lookup_keys by order initially requested
  def get_stripe_data(price_lookup_key)

    prices = Rails.cache.fetch("#{price_lookup_key}/get_stripe_data", expires_in: 1.hours) do
      Stripe::Price.list({ lookup_keys:[price_lookup_key,
                                        ENV['STRIPE_DEFAULT_LOOKUP_KEY']] })
    end

    price = prices[:data].find{ |price| price['lookup_key'] == price_lookup_key } ||
            prices[:data].find{ |price| price['lookup_key'] == ENV['STRIPE_DEFAULT_LOOKUP_KEY'] }

    return price
  end

  #GET initial request (#new) -> lookup_key
  #
  # lookup_key is our text 'nick' handle that representing the
  # "current" product/price
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

  def stripe_redirect_host()
    [request.protocol, request.host_with_port].join
  end
end
