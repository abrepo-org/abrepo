require "test_helper"
require "minitest/mock"

class UsersFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup

    @stripe_price = {
      'object' => 'list',
      'data' => [
        {
          'id' => 'price_123',
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

    @checkout_session_id = "cs_test_123"

    @checkout_session_params = {
      customer: nil,
      customer_email: nil,
      client_reference_id: 1,
      subscription_data: {metadata: {abrepo_email: "test@example.com", user_id: 1 }},
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

    @stripe_subscription_id = "sub_test_123"
    @stripe_subscription_return = Stripe::Util.convert_to_stripe_object(
      {
        client_reference_id: "1",
        customer: "cus_test_123",
        subscription: @stripe_subscription_id,
        payment_status: "paid"
      }
    )

    @user_two = users(:user_two)

    # hacky way to know the user_id beforehand (user id 1) for use in
    # @checkout_session_params
    ActiveRecord::Base.connection.execute("TRUNCATE users RESTART IDENTITY CASCADE")

  end

  test "user signs up, ends up with active subscription; mailer sends to email address " do
    Rails.cache.clear
    stripe_price_mock = Minitest::Mock.new
    stripe_price_mock.expect(:call, @mock_stripe_price, [@stripe_price_params])

    # splat, because Session create method takes named parameters
    checkout_session_mock = Minitest::Mock.new
    checkout_session_mock.expect(:call, @checkout_session_return, **@checkout_session_params)

    success_mock = Minitest::Mock.new
    success_mock.expect(:call, @stripe_subscription_return, [@checkout_session_id])

    Stripe::Price.stub(:list, stripe_price_mock) do
      Stripe::Checkout::Session.stub(:create, checkout_session_mock) do
        Stripe::Checkout::Session.stub(:retrieve, success_mock) do
          # 1. visit sign-up page /users/sign-up -> redirects to checkout/account/basic-monthly
          get new_user_registration_path
          assert_redirected_to checkout_account_path(@stripe_price_params[:lookup_keys].first)

          # NB: avoid follow_redirect! slow unless caching :memory_store
          # enabled but want to avoid that in testing env

          # 2. fill in and submit (stubbed stripe calls)
          assert_difference 'User.count', 1 do
            post checkout_user_create_path, params: {
                   lookup_key: 'basic-monthly',
                   data: {:price_key => 'basic-monthly'},
                   user: { email: "test@example.com", password: 'password' }
                 }

            # 3. User created
          end

          # no subscription yet require stripe callback
          user = User.last
          assert_not user.confirmed?
          assert_not user.subscribed?
          assert_nil user.stripe_subscription

          # 4. successful mailer confirmation sent
          assert_not ActionMailer::Base.deliveries.empty?
          assert_equal user.email, ActionMailer::Base.deliveries.last.to.first

          # 5. stripe subscription callback
          assert_empty user.subscriptions
          get checkout_success_path params: {session_id: @checkout_session_id}
          assert_not_empty user.subscriptions

          # 6. redirects to home_path after successful sign up
          assert_equal flash[:notice], "Your subscription is enabled. Thank you!"
          assert_redirected_to home_path

        end
      end
    end

    assert stripe_price_mock.verify
    assert checkout_session_mock.verify
    assert success_mock.verify

    #
    # ensure user subscription methods
    #
    subscription_mock = Minitest::Mock.new
    subscription_mock.expect(:call, @stripe_subscription_return, [@stripe_subscription_id])

    Stripe::Subscription.stub(:retrieve, subscription_mock) do
      user = User.last
      assert user.subscribed?
      assert_equal user.stripe_subscription.subscription, @stripe_subscription_id
    end

  end


  test "user logs in has access to settings page, logged out does not" do
    Rails.cache.clear
    get users_edit_path
    assert_redirected_to new_user_session_path

    sign_in @user_two
    get users_edit_path
    assert_response :success
  end

end
