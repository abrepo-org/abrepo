require_relative 'boot'

#require 'rails/all'
require "rails"
require "action_cable/engine"

# This list is here as documentation only - it's not used
# NB: to enable active_storage: check env files (development.rb)
# and uncomment config.active_storage lines
omitted = %w(
  action_cable/engine
  action_mailbox/engine
  action_text/engine
  active_storage/engine
)

# Only the frameworks in Rails that do not pollute our routes
%w(
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  rails/test_unit/railtie
  sprockets/railtie
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.generators.javascript_engine = :js
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.app_title = "ABREPO"

    # number of records / elements in a collection fully visible
    # before obfuscation. Records beyond first page are
    # obfuscated (see application_controller:num_from_pagination)
    #
    # NB: non-existent 'overflow' pages return empty result
    # (see config/initializers/pagy.rb)
    config.num_obfuscate = 5

    # stored in session cookie num_visits to variation#show
    # used by ApplicationController:obfuscate_num_visits_variation_show
    # session[:num_visits_variation_show]

    config.max_visits_variation_show = 7
  end
end
