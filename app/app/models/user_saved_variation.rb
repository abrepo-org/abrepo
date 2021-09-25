# == Schema Information
#
# Table name: user_saved_variations
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint
#  variation_id :bigint
#
# Indexes
#
#  index_user_saved_variations_on_user_id       (user_id)
#  index_user_saved_variations_on_variation_id  (variation_id)
#
class UserSavedVariation < ApplicationRecord
  belongs_to :user
  belongs_to :variation
end
