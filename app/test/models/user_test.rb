# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  moderator              :boolean          default(FALSE)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
require "test_helper"

#
# NB: coverage error from simplecov. Who knows. Combination w/ devise likely
# culprit.
#
class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_two)
  end

  test 'valid user' do
    assert @user.valid?
  end

  test 'email presence' do
    @user.email = nil
    assert_not @user.valid?
  end

  test 'email uniqueness' do
    new_user = User.new(
      email: @user.email,
      password: 'password',
      password_confirmation: 'password'
    )

    assert_not new_user.valid?
    assert_includes new_user.errors[:email], 'has already been taken'
  end

  test 'password presence' do
    new_user = User.new(
      email: "abc@email.com",
      password: '',
      password_confirmation: ''
    )

    assert_not new_user.valid?
    assert_includes new_user.errors[:password], "can't be blank"
  end

  test 'subscribed? returns true when there are active subscriptions' do
    # NB: these are set in fixtures
    active_subscribed_user = users(:user_one)
    assert active_subscribed_user.subscribed?
  end

  test 'subscribed? returns false when there are no active subscriptions' do
    # NB: these are set in fixtures
    inactive_subscribed_user = users(:user_two);
    assert_not inactive_subscribed_user.subscribed?
  end

  test 'stripe_subscription returns nil if no subscriptions' do
    new_user = User.new(
      email: 'test@test.com',
      password: 'password',
      password_confirmation: 'password'
    )

    assert_nil new_user.stripe_subscription
  end

  test 'stripe_subscription retrieves the correct Stripe subscription' do
    skip "covered by integration test"
  end

end
