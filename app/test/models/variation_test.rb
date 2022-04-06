# == Schema Information
#
# Table name: variations
#
#  id            :bigint           not null, primary key
#  audience_name :string
#  published     :boolean          default(FALSE)
#  summary_name  :string
#  url           :string
#  verified      :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  a_id          :string
#  experiment_id :bigint
#  vendor_id     :string
#
# Indexes
#
#  index_variations_on_experiment_id  (experiment_id)
#
# Foreign Keys
#
#  fk_rails_...  (experiment_id => experiments.id)
#

require 'test_helper'

class VariationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
