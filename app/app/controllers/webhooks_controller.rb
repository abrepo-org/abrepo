class WebhooksController < ApplicationController
  protect_from_forgery :except => :index

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

        puts "checkout.session.completed"

        #save customer id to db
        puts "CUSTOMER", data_object['customer']
        #puts event

      when 'invoice.paid'
        puts "invoice paid"
        puts event
      when 'invoice.payment.failed'
        puts "invoice payment failed"
        puts event
      else
        puts "Unhandled event type: #{event_type}"
        puts event
      end

    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      status 400
      return

      #TODO: some generic catch all error
    end


    #endpoint must return a 2xx HTTP
    render status: 200, json: {}
  end

end
