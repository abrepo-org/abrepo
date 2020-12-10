# == Schema Information
#
# Table name: renderables
#
#  id                 :bigint           not null, primary key
#  control            :boolean
#  diff               :json
#  domain             :string
#  renderedTitle      :string
#  renderedURL        :string
#  screenshotFilename :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  a_id               :string
#  action_id          :bigint
#  renderable_id      :bigint
#  variation_id       :bigint
#
# Indexes
#
#  index_renderables_on_action_id      (action_id)
#  index_renderables_on_renderable_id  (renderable_id)
#  index_renderables_on_variation_id   (variation_id)
#
# Foreign Keys
#
#  fk_rails_...  (action_id => actions.id)
#  fk_rails_...  (variation_id => variations.id)
#

require 'test_helper'

class RenderableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
