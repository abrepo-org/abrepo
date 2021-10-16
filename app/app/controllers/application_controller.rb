class ApplicationController < ActionController::Base
  include Pundit
  include Pagy::Backend

  def subscribed_or_moderator
    (user_signed_in? &&
     (current_user.subscribed? || current_user.moderator?))
  end


  def obfuscate_all(instances, num_start)
    instances.each_with_index do |instance, index|
      instance.obfuscate if index >= num_start && instance.respond_to?('obfuscate')
    end

    instances
  end

  # need to accommodate pagination: don't want num visible per page
  # which happens if we obfuscate_all(4) each ?page=2 we want
  # obfuscation after 4, which would mean results on every page 2+
  # obfuscated

  def num_from_pagination(num = Rails.application.config.num_obfuscate)
    # pagy breaks on excessive page param, so if exceed pages
    # behave like first page (since that's what's returned)
    params[:page] && params[:page].to_i > 1 ? 0.to_i : num.to_i
  end

  helper_method :subscribed_or_moderator, :obfuscate_all, :num_from_pagination

end
