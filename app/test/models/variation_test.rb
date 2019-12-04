# == Schema Information
#
# Table name: variations
#
#  id            :bigint           not null, primary key
#  control       :boolean
#  name          :string
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  experiment_id :bigint
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
