# == Schema Information
#
# Table name: vendors
#
#  id            :bigint           not null, primary key
#  campaignID    :string
#  experimentID  :string
#  name          :string
#  variantID     :string
#  variationID   :string
#  viewID        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  experiment_id :bigint
#  variation_id  :bigint
#
# Indexes
#
#  index_vendors_on_experiment_id  (experiment_id)
#  index_vendors_on_variation_id   (variation_id)
#
# Foreign Keys
#
#  fk_rails_...  (experiment_id => experiments.id)
#  fk_rails_...  (variation_id => variations.id)
#

require 'test_helper'

class VendorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
