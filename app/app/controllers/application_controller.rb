class ApplicationController < ActionController::Base
  include Pundit
  include Pagy::Backend

  def subscribed_or_moderator
    (user_signed_in? &&
     (current_user.subscribed? || current_user.moderator?))
  end

  # active check for imports only user
  def require_moderator
    redirect_to root_path unless (user_signed_in? && current_user.moderator?)
  end

  def obfuscate_from(instances, num_start)
    instances.each_with_index do |instance, index|
      instance.obfuscate if index >= num_start && instance.respond_to?('obfuscate')
    end

    instances
  end

  def obfuscate_num_visits_variation_show(limit)
    if session.present? && (not subscribed_or_moderator)
      session[:num_visits_variation_show] ||= 0
      session[:num_visits_variation_show] += 1
      return session[:num_visits_variation_show] >= limit
    end
    return false
  end

  #
  # need to accommodate pagination: don't want num visible *per* page
  # e.g. obfuscate_all(4) on ?page=2 shows first _num_ on each page, we
  # want everything obfuscated after _num_
  #
  def num_given_pagination(max_len, override_num = false)

    # currently take min ( ~5 config or N/2)
    # (e.g. if < 5, obfuscate at least some)
    num_visible = override_num ||
                  [Rails.application.config.num_obfuscate.to_i,
                   (max_len / 2.0).ceil].min

    # past page 1, obfuscate all
    params[:page] && params[:page].to_i > 1 ? 0.to_i : num_visible
  end

  helper_method :subscribed_or_moderator, :obfuscate_from, :num_given_pagination


  protected
  ### Devise override

  def after_sign_in_path_for(resource)
    home_path
  end
end
