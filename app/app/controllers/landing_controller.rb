class LandingController < ApplicationController
  include CheckoutHelper

  def index
    #
    # Maintenance mode flash
    # flash[:alert] = "Currently in maintenance mode"
    #

    @profiles = []

    #[query, description] pairs
    @search_queries = [
      ['CTA [hero]', '"CTA" experiments tagged with "hero"'],
      ['navbar {internet}', '"navbar" experiments within "internet" industry'],
      ['redirect', '"redirect" experiments'],
      ['header [signup-page]', '"header" experiments on "signup-page"'],
      ['webinar', '"webinar" experiments']
    ]

    # TODO: change to query Profiles with Experiments > 3 + logo?
    # Tags are hardcoded in /landing/_hero_tags.html.erb (expensive
    # queries to discern taggable_type - industry/variation to build
    # query url)

    domains = [ 'bigcommerce.com', 'zillow.com','gartner.com',
                'slack.com', 'elastic.com', 'change.org', 'doordash.com',
                'hootsuite.com']

    @profiles = Profile.where(domain: domains)


    #NB: helper currently returns 'basic-monthly', 'basic-annual' lookup keys
    @basic_monthly_price, @basic_annual_price = get_all_stripe_data
  end
end
