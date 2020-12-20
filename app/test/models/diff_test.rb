# == Schema Information
#
# Table name: diffs
#
#  id            :bigint           not null, primary key
#  calculated    :json
#  crawlId       :string
#  diffSummary   :json
#  diffType      :string
#  is_ignore     :boolean
#  newDim        :json
#  origDim       :json
#  selector      :string
#  summarization :json
#  visible       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  a_id          :string
#  renderable_id :bigint
#
# Indexes
#
#  index_diffs_on_renderable_id  (renderable_id)
#
# Foreign Keys
#
#  fk_rails_...  (renderable_id => renderables.id)
#

require 'test_helper'

class DiffTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
