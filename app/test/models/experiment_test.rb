# == Schema Information
#
# Table name: experiments
#
#  id                :bigint           not null, primary key
#  crawlID           :string
#  domain            :string
#  experimentSummary :string
#  gen_desc          :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  a_id              :string
#  profile_id        :bigint
#
# Indexes
#
#  index_experiments_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#

require 'test_helper'

class ExperimentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
