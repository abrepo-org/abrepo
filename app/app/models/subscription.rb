# == Schema Information
#
# Table name: subscriptions
#
#  id                     :bigint           not null, primary key
#  active                 :boolean          default(FALSE), not null
#  billing_issue          :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  stripe_customer_id     :string
#  stripe_subscription_id :string
#  user_id                :bigint
#
# Indexes
#
#  index_subscriptions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Subscription < ApplicationRecord
  belongs_to :user

  #'active', 'billing_issue' are catch all toggles used to indicate if
  #user has paid and access is allowed. Finer status is to be taken
  #from stripe - want Stripe as source of truth.
  validates :user_id, :stripe_customer_id, :stripe_subscription_id, presence: true
end
