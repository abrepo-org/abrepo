require "test_helper"
require "minitest/mock"
require "ostruct"

class StripeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:user_one)
    sign_in @user

    @session_id = "cs_test_123"
    @price_key = "price_123"
    @stripe_session_return = Stripe::Util.convert_to_stripe_object(
      {
        client_reference_id: @user.id.to_s,
        customer: "cus_test_123",
        subscription: "sub_test_123",
        payment_status: "paid"
      }
    )

    @stripe_price = {
      'object' => 'list',
      'data' => [
        {
          'id' => @price_key,
          'lookup_key' => 'basic-monthly',
          'nickname' => 'Monthly Subscription',
          'product' => 'prod_abc',
          'unit_amount' => 1234,
          'unit_amount_decimal' => "1234",
          "recurring" => {
            "aggregate_usage": nil,
                          "interval":"month",
                          "interval_count":1,
                          "meter": nil,
                          "trial_period_days": nil,
                          "usage_type":"licensed"
          },
        }
      ],
      'has_more' => false,
      'url' => '/v1/prices'
    }

    @mock_stripe_price = Stripe::Util.convert_to_stripe_object(@stripe_price, "xyz")

    @stripe_price_params = {
      lookup_keys: [@stripe_price['data'][0]['lookup_key'], ENV['STRIPE_DEFAULT_LOOKUP_KEY']]
    }

    @checkout_session_params = {
      customer: nil,
      customer_email: @user.email,
      client_reference_id: 1,
      subscription_data: {metadata: {abrepo_email: @user.email, user_id: @user.id}},
      success_url: "http://www.example.com/checkout/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "http://www.example.com/#pricing",
      payment_method_types: ["card"],
      mode: "subscription",
      allow_promotion_codes: true,
      line_items: [{quantity: 1, price: "price_123"}]
    }

    @checkout_session_return = Stripe::Util.convert_to_stripe_object(
      { id: 'session_123', url: 'http://example.com/checkout' }, "xyz"
    )
  end

  # create_checkout_session POST   /create-checkout-session(.:format)        stripe#createSession
  # checkout_success GET    /checkout/success(.:format)               stripe#success
  # webhooks_stripe_payments POST   /webhooks/stripe_payments(.:format)       webhooks#index
  # customer_portal POST   /customer-portal(.:format)                stripe#portal

  #@mock_stripe_price = Stripe::Util.convert_to_stripe_object(@stripe_price, "xyz")

  test "should redirect to root if session_id is nil on success" do
    get checkout_success_path, params: { session_id: nil }
    assert_redirected_to root_path(anchor: "pricing")
  end


  test "should set flash notice and redirect to home on success with valid session_id" do

    session_mock = Minitest::Mock.new
    session_mock.expect(:call, @stripe_session_return, [@session_id])

    Stripe::Checkout::Session.stub(:retrieve, session_mock) do

        assert_difference 'Subscription.count', 1 do
          get checkout_success_path, params: { session_id: @session_id }
        end

        assert_equal flash[:notice], "Your subscription is enabled. Thank you!"
        assert_redirected_to home_path
    end

    assert session_mock.verify
  end


  test "should not create subscription on success with invalid session" do
    raises_exception = -> (session_id) { raise Stripe::StripeError.new("Error") }
    Stripe::Checkout::Session.stub(:retrieve, raises_exception) do

      get checkout_success_path, params: { session_id: @session_id }

      assert_response :redirect
      assert_equal "Your subscription is enabled. Thank you!", flash[:notice]
    end
  end


  # this differs from checkout_controller because user was already created
  # but did not initially subscribe; however now enables a subscription
  test "should return session id on createSession with valid price_key" do

    Rails.cache.clear

    stripe_price_mock = Minitest::Mock.new
    stripe_price_mock.expect(:call, @mock_stripe_price, [@stripe_price_params])

    checkout_session_mock = Minitest::Mock.new
    checkout_session_mock.expect(:call, @checkout_session_return, **@checkout_session_params)


    Stripe::Price.stub(:list, stripe_price_mock) do

      Stripe::Checkout::Session.stub(:create, checkout_session_mock) do
        post create_checkout_session_path, params: { data: {price_key: 'basic-monthly'} }
        assert_response :success
        json_response = JSON.parse(@response.body)
        assert_equal "session_123", json_response["stripe"]["sessionId"]
      end
    end

    assert stripe_price_mock.verify
    assert checkout_session_mock.verify
  end

  test "should return error on createSession with invalid behavior" do
    Rails.cache.clear

    stripe_price_mock = Minitest::Mock.new
    stripe_price_mock.expect(:call, @mock_stripe_price, [@stripe_price_params])

    # trigger some kind of error
    raises_exception = -> (session_id) { raise Stripe::StripeError.new("Error") }

    Stripe::Price.stub(:list, stripe_price_mock) do

      Stripe::Checkout::Session.stub(:create, raises_exception) do
        post create_checkout_session_path, params: { data: {price_key: 'basic-monthly'} }
        assert_response 400
        json_response = JSON.parse(@response.body)
        assert_equal false, json_response["stripe"]["ok"]
      end
    end

    assert stripe_price_mock.verify
  end

  test "should return billing portal URL on portal" do
    sign_in @user
    subscription = Subscription.new(stripe_subscription_id: "abc",
                                    stripe_customer_id: "123",
                                    user: @user)
    @user.subscriptions = [subscription]

    url = "http://www.example.com/users/edit";
    billing_params = {
      customer: "123",
      return_url: url
    }

    billing_portal_mock = Minitest::Mock.new
    billing_portal_mock.expect(:call,  OpenStruct.new(url: url),  [billing_params])


    Stripe::BillingPortal::Session.stub(:create, billing_portal_mock) do
      post customer_portal_path
      assert_response :success
      json_response = JSON.parse(@response.body)
      assert_equal url, json_response["url"]
    end

  end

end
