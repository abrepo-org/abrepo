class CheckoutController < Devise::RegistrationsController
  include CheckoutHelper

  # require_no_authentication: if signed in, redirects to root/etc, don't visit new/create
  # allows us to avoid re-creating users if user exist
  # for /initial we have our own redirect to checkout_subscribe_path (vs root)
  # prepend_before_action :require_no_authentication, only: [:create]

  #sets a controller variable @minimum_password_length
  prepend_before_action :set_minimum_password_length, only: [:initial]


  #
  # need a separate action to avoid prepend_before_action hooks so we
  # can actually execute custom controller / hook code like redirects
  # this is basically a prepended Devise::RegistrationsController#new
  #
  def account
    if user_signed_in?
      redirect_to checkout_subscribe_path( params_lookup_key )
      return
    end

    @price_key, @price = get_stripe_data

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

    unless (resource.valid?)
      clean_up_passwords resource
      set_minimum_password_length
      render status: 400, json: { user: { ok: false,
                                          errors: { messages: resource.errors.full_messages } },
                                  stripe: nil }
      return
    end

    @price_key, @price = get_stripe_data
    session = nil

    begin
      session = purchase_stripe(@price.id, @price_key)
    rescue => e
      message = "Payment provider error. Please try again."
      render status: 400, json: { user: {ok: true, errors: false},
                                  stripe: { ok: false, errors: { messages: [ message ] } }}
      return
    end


    resource.save

    if resource.persisted?
      if resource.active_for_authentication?
        #set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)

        render status: 200, json: { user: { ok: true, errors: false },
                                    stripe: { ok: true, errors: false, sessionId: session.id }}
        return


        #render status 200: json: {user: 'success', sessionId: 'sessionId'}
        #respond_with resource, location: after_sign_up_path_for(resource)

      else
        #set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        render status: 400, json: { user: { ok: false,
                                            errors: { messages: [resource.inactive_message] }},
                                    stripe: nil }
        return
        #respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render status: 400, json: { user: { ok: false,
                                          errors: { messages: resource.errors.full_messages } },
                                  stripe: nil }
      #respond_with resource
      #render :initial
    end
  end

  #
  # DEVISE OVERRIDES
  #
  # /users/sign_up - redirect when not signed up
  #
  def new
    redirect_to checkout_account_path( params_lookup_key )
  end

  #
  # https://github.com/heartcombo/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-in,-sign-up,-or-sign-out
  #
  #
  def after_sign_up_path_for(resource)
    return checkout_subscribe_path(params[:lookup_key]) unless params[:lookup_key].blank?
    root_path
  end

  def get_stripe_data
    price_key = params_lookup_key #sets default if no params
    prices = Stripe::Price.list({ lookup_keys:[price_key, ENV['STRIPE_DEFAULT_LOOKUP_KEY']] })
    # NB: assmue prices respects lookup_keys order, but not entirely sure.
    price = prices[:data].first
    return price_key, price
  end
end
