module CheckoutHelper
  #
  # these are mutually exclusive, prefer customer, otherwise email if
  # available
  #
  def params_lookup_key
    #NB: this is for devise routes not stripe
    return params[:lookup_key] || ENV['STRIPE_DEFAULT_LOOKUP_KEY']
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
