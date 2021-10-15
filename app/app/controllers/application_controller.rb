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


  helper_method :subscribed_or_moderator, :obfuscate_all

end
