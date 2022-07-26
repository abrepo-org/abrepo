class ConfirmationsController < Devise::ConfirmationsController

  private

  # override for confirm email link
  # want to send to home_path (vs root_path)
  #
  # can send email in rails c via
  # 'user.send_confirmation_instructions'
  def after_confirmation_path_for(resource_name, resource)
    home_path
  end

end
