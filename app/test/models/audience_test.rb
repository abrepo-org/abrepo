# == Schema Information
#
# Table name: audiences
#
#  id            :bigint           not null, primary key
#  description   :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  experiment_id :bigint
#
# Indexes
#
#  index_audiences_on_experiment_id  (experiment_id)
#
# Foreign Keys
#
#  fk_rails_...  (experiment_id => experiments.id)
#

require 'test_helper'

class AudienceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
