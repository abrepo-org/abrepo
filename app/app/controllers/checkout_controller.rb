class CheckoutController < Devise::RegistrationsController
  include CheckoutHelper

  # require_no_authentication: if signed in, redirects to root/etc, don't visit new/create
  # allows us to avoid re-creating users if user exist
  # for /initial we have our own redirect to checkout_review_path (vs root)
  prepend_before_action :require_no_authentication, only: [:create]

  #sets a controller variable @minimum_password_length
  prepend_before_action :set_minimum_password_length, only: [:initial]


  #
  # need a separate action to avoid prepend_before_action hooks so we
  # can actually execute custom controller / hook code like redirects
  # this is basically a prepended Devise::RegistrationsController#new
  #
  def initial

    if user_signed_in?
      redirect_to checkout_review_path( params_price_key )
      return
    end

    #registration#new
    build_resource
    yield resource if block_given?
    respond_with resource
  end

  #
  # devise: registrations#create
  # modified last line to render checkout view on error (defaults to :new)
  #
  def create

    build_resource(sign_up_params)
    resource.skip_confirmation_notification! #if purchased, set confirmed
    resource.save

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      #respond_with resource
      render :initial
    end
  end

  #
  # DEVISE OVERRIDES
  #
  # /users/sign_up - redirect when not signed up
  #
  def new
    redirect_to checkout_initial_path( params_price_key )
  end

  #
  # https://github.com/heartcombo/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-in,-sign-up,-or-sign-out
  #
  #
  def after_sign_up_path_for(resource)
    return checkout_review_path(params[:price_key]) unless params[:price_key].blank?
    root_path
  end

end
