module CheckoutHelper
  #
  # these are mutually exclusive, prefer customer, otherwise email if
  # available
  #
  def params_price_key
    params[:price_key] || "basic"
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
