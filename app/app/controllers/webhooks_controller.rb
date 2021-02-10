class WebhooksController < ApplicationController
  protect_from_forgery with: :exception, :except => :index

  def index
    webhook_secret = ENV['STRIPE_WEBHOOK_SECRET_KEY']

    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, webhook_secret
      )

      data = JSON.parse(payload, symbolize_names: true)
      event = Stripe::Event.construct_from(data)

      # Get the type of webhook event sent
      # https://stripe.com/docs/api/events/types
      event_type = event['type']
      data = event['data']
      data_object = data['object']

      #not sure what I need here...maybe just keep a log?
      puts "EVENT: #{event_type}"

      case event.type
      when 'checkout.session.completed'

        #data obj is "checkout.session"
        user_id = data_object['client_reference_id']

        #potential place for building user?
        #user = User.find_by_id(user_id)
        # if (user.nil?):
        #     email = data_object['customer_details']['email']
        #   user = User.create(email: email)

        #paid user, assumed confirmed
        current_user.confirm

        subscription = Subscription.create(
            user_id: user_id,
            stripe_customer_id: data_object['customer'],
            stripe_subscription_id: data_object['subscription'],
            active: data_object['payment_status'] == "paid",
            billing_issue: data_object['payment_status'] != "paid"
        );


      #
      # No Sub
      #
      when 'customer.subscription.deleted'
        stripe_subscription_id = data_object['id']
        subscription = Subscription.find_by_stripe_subscription_id(stripe_subscription_id)
        subscription.update(active: false, billing_issue: false) if subscription

      #
      # No Sub - arrears
      #
      # 'charge.failed', 'invoice.payment_failed' -> ultimately subscription is updated
      # past_due, unpaid, incomplete, incomplete_expired,
      when 'charge.failed', 'invoice.payment_failed'

        if data_object['subscription']
          stripe_subscription_id = data_object['subscription']
          stripe_subscription = Stripe::Subscription.retrieve(stripe_subscription_id)
          status = stripe_subscription['status']

          if not ['active', 'trialing', 'canceled'].include?(status)
            subscription = Subscription.find_by_stripe_subscription_id(stripe_subscription_id)
            subscription.update(active: false, billing_issue: true) if subscription
          end
        end

      # when 'charge.dispute.created'
      # when 'radar.early_fraud_warning.created'
      # active:true, billing_issue: false? a flag - we'll allow access until resolved?

      else
        puts "Unhandled event type: #{event_type}"

      end


    rescue JSON::ParserError => e
      # Invalid payload
      puts "Invalid Payload", e
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      puts "Invalid Signature", e
      status 400
      return

      #TODO: some generic catch all error
    end


    #endpoint must return a 2xx HTTP
    render status: 200, json: {}
  end

end
