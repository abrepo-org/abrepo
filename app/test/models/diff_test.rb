# == Schema Information
#
# Table name: diffs
#
#  id                     :bigint           not null, primary key
#  calculated             :json
#  crawlId                :string
#  diffPanel              :string           default("true")
#  diffType               :string
#  newDim                 :json
#  origDim                :json
#  selector               :string
#  selectorDisplayName    :string
#  summary_added          :string
#  summary_added_format   :string
#  summary_delta          :string
#  summary_removed        :string
#  summary_removed_format :string
#  viewMode               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  a_id                   :string
#  group_id               :string
#  renderable_id          :bigint
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
