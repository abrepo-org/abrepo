# == Schema Information
#
# Table name: variations
#
#  id               :bigint           not null, primary key
#  gen_desc         :string
#  name             :string
#  url              :string
#  variationSummary :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  a_id             :string
#  experiment_id    :bigint
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
