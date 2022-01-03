class LandingController < ApplicationController
  include CheckoutHelper

  def index
    #
    # Maintenance mode flash
    # flash[:alert] = "Currently in maintenance mode"
    #

    #NB: helper currently returns 'basic-monthly', 'basic-annual' lookup keys
    @basic_monthly_price, @basic_annual_price = get_all_stripe_data
  end

  #
  # combination with config/routes.rb
  # *path redirects all requests back to landing page
  #
  def redirect
    redirect_to action: 'index', controller: 'landing'
  end
end
