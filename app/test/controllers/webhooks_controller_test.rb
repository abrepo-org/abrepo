# frozen_string_literal: true
require "test_helper"
require "minitest/mock"

class WebhooksControllerTest < ActionDispatch::IntegrationTest

  def setup
    @subscription = subscriptions(:subscription_one)
    @controller = WebhooksController.new
    @webhook_secret = 'whsec_test_secret'
    ENV['STRIPE_WEBHOOK_SECRET_KEY'] = @webhook_secret
  end

  def teardown
    ENV['STRIPE_WEBHOOK_SECRET_KEY'] = nil
  end

  test "should handle checkout.session.completed event" do

    payload = {
      "id" => "event_id",
      "type" => "checkout.session.completed",
      "data" => {
        "object" => {
          "client_reference_id" => @subscription.user.id,
          "customer" => @subscription.stripe_customer_id,
          "subscription" => @subscription.stripe_subscription_id,
          "payment_status" => "paid"
        }
      }
    }.to_json

    sig_header = "t=1234567890,v1=hash_value"

    Stripe::Webhook.stub :construct_event, true do
      post webhooks_stripe_payments_path, params: payload, headers: { "HTTP_STRIPE_SIGNATURE" => sig_header }

      assert_response :success
      subscription = Subscription.find_by_stripe_subscription_id(@subscription.stripe_subscription_id)
      assert subscription.active
      assert !subscription.billing_issue
    end
  end

  test "should handle customer.subscription.deleted event" do
    sub_id = "sub_id_123"
    payload = {
      "id" => "event_id",
      "type" => "customer.subscription.deleted",
      "data" => {
        "object" => {
          "id" => sub_id
        }
      }
    }.to_json

    sig_header = "t=1234567890,v1=hash_value"

    subscription = Subscription.create!(
      user_id: @subscription.user.id,
      stripe_customer_id: @subscription.stripe_customer_id,
      stripe_subscription_id: sub_id,
      active: true)

    Stripe::Webhook.stub :construct_event, true do
      post webhooks_stripe_payments_path, params: payload, headers: { "HTTP_STRIPE_SIGNATURE" => sig_header }
      assert_response :success
      subscription = Subscription.find_by_stripe_subscription_id(sub_id)
      subscription.reload
      assert_not subscription.active
      assert_not subscription.billing_issue
    end
  end


  test "should handle charge.failed event" do
    sub_id = "sub_id_123"
    payload = {
      "id" => "event_id",
      "type" => "charge.failed",
      "data" => {
        "object" => {
          "subscription" => "sub_id_123"
        }
      }
    }.to_json

    sig_header = "t=1234567890,v1=hash_value"

    subscription = Subscription.create!(
      user_id: @subscription.user.id,
      stripe_customer_id: @subscription.stripe_customer_id,
      stripe_subscription_id: sub_id,
      active: true)

    Stripe::Subscription.stub :retrieve, { 'status' => 'past_due' } do
      Stripe::Webhook.stub :construct_event, true do
        post webhooks_stripe_payments_path, params: payload, headers: { "HTTP_STRIPE_SIGNATURE" => sig_header }

        assert_response :success
        subscription.reload
        assert_not subscription.active
        assert subscription.billing_issue
      end
    end
  end

  test "should return 400 for invalid payload" do
    payload = "invalid_json"
    sig_header = "t=1234567890,v1=hash_value"

    # Adjust the stub to accept two arguments, matching the signature of the method
    Stripe::Webhook.stub :construct_event, -> (payload, sig_header, webhook_secret) { raise JSON::ParserError.new("Invalid JSON") } do
      post webhooks_stripe_payments_path, params: payload, headers: { "HTTP_STRIPE_SIGNATURE" => sig_header }
      assert_response :bad_request
    end
  end

  test "should return 400 for invalid signature" do
    payload = {
      "id" => "event_id",
      "type" => "checkout.session.completed",
      "data" => {
        "object" => {}
      }
    }.to_json

    sig_header = "invalid_signature"

    Stripe::Webhook.stub :construct_event, -> (payload, sig_header, webhook_secret) { raise Stripe::SignatureVerificationError.new("Invalid signature", "xyz") } do
      post webhooks_stripe_payments_path, params: payload, headers: { "HTTP_STRIPE_SIGNATURE" => sig_header }
      assert_response :bad_request
    end
  end

end
