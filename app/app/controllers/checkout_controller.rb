class CheckoutController < Devise::RegistrationsController
  include CheckoutHelper

  #
  # need a separate action to avoid prepend_before_action hooks so we
  # can actually execute custom controller / hook code like redirects
  # this is basically a prepended
  # Devise::RegistrationsController#new
  #
  def account
    if user_signed_in?
      redirect_to root_path(anchor: "pricing")
      return
    end

    @price_key = params_lookup_key
    @price = get_stripe_data(@price_key)

    #registration#new
    build_resource
    yield resource if block_given?
    respond_with resource
  end

  # devise: registrations#edit (/users/edit)
  # override to insert @subscription instance var
  def edit
    @subscription = current_user.stripe_subscription
    super
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


    resource.save

    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)

        #
        # created account, now send to stripe
        # want email to be auto sent to stripe (less friction)
        #

        @price_key = params_price_key
        @price = get_stripe_data(@price_key)
        session = nil

        begin
          session = purchase_stripe(@price.id, @price_key)
        rescue => e
          message = "Payment provider error. Please try again."
          render status: 400, json: { user: {ok: true, errors: false},
                                      stripe: { ok: false, errors: { messages: [ message ] } }}
          return
        end

        render status: 200, json: { user: { ok: true, errors: false },
                                    stripe: { ok: true, errors: false, sessionId: session.id }}
        return

      else

        expire_data_after_sign_in!
        render status: 400, json: { user: { ok: false,
                                            errors: { messages: [resource.inactive_message] }},
                                    stripe: nil }
        return

      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render status: 400, json: { user: { ok: false,
                                          errors: { messages: resource.errors.full_messages } },
                                  stripe: nil }
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
    home_path
  end

end
