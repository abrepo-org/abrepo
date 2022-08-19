class LandingController < ApplicationController
  include CheckoutHelper

  def index
    #
    # Maintenance mode flash
    # flash[:alert] = "Currently in maintenance mode"
    #

    @profiles = []

    # TODO: change to query Profiles with Experiments > 3 + logo?
    # Tags are hardcoded in /landing/_hero_tags.html.erb (expensive
    # queries to discern taggable_type - industry/variation to build
    # query url)

    domains = [
      'showtime.com', 'bigcommerce.com', 'aspca.org', 'hostgator.com', 'elastic.com', 'freshdesk.com', 'sofi.com', 'mongodb.com'
    ]

    if ENV['RAILS_ENV'] == "development"
      domains = [
        'bigcommerce.com', 'zillow.com','gartner.com', 'slack.com', 'mindbody.com', 'change.org', 'doordash.com', 'hootsuite.com']
    end

    @profiles = Profile.where(domain: domains)


    #NB: helper currently returns 'basic-monthly', 'basic-annual' lookup keys
    @basic_monthly_price, @basic_annual_price = get_all_stripe_data
  end
end
