# == Schema Information
#
# Table name: experiments
#
#  id               :bigint           not null, primary key
#  audience_name    :string
#  calcscore        :float            default(0.0)
#  crawlId          :string
#  domain           :string
#  published        :boolean          default(FALSE)
#  summary_name     :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  a_id             :string
#  profile_id       :bigint
#  source_vendor_id :bigint
#  vendor_id        :string
#
# Indexes
#
#  index_experiments_on_profile_id        (profile_id)
#  index_experiments_on_source_vendor_id  (source_vendor_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (source_vendor_id => source_vendors.id)
#

require 'test_helper'

class ExperimentTest < ActiveSupport::TestCase

  def setup
    @experiment = experiments(:experiment_one)
  end

  test "should obfuscate attributes" do
    original_summary = @experiment.summary_name
    original_audience = @experiment.audience_name
    original_domain = @experiment.domain

    @experiment.obfuscate

    assert_not_equal original_summary, @experiment.summary_name
    assert_not_equal original_audience, @experiment.audience_name
    assert_not_equal original_domain, @experiment.domain
    assert @experiment.obfuscated
  end

end
