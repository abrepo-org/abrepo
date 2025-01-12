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

  def setup
    @variation = renderables(:renderable_one).variation
    @renderable1 = renderables(:renderable_one)
  end

  test 'visibleActions returns actions from associated renderables that are not nil' do

    preExecuteAction = @renderable1['preExecuteAction']

    # see renderable:preExecuteAction()
    preExecuteAction["id"] = @renderable1.action.id
    preExecuteAction["actionType"] = @renderable1.action['type']

    expected_result = {
      active: [@renderable1['preExecuteAction']],
      control: [nil] # controlRenderable's action
    }

    assert_equal expected_result, @variation.visibleActions
  end


  test "should obfuscate attributes" do
    original_summary = @variation.summary_name
    original_url = @variation.url

    @variation.obfuscate

    assert_not_equal original_summary, @variation.summary_name
    assert_not_equal original_url, @variation.url
    assert @variation.obfuscated
  end

end
