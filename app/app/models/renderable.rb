# == Schema Information
#
# Table name: renderables
#
#  id                 :bigint           not null, primary key
#  domain             :string
#  renderedTitle      :string
#  renderedURL        :string
#  screenshotFilename :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  action_id          :bigint
#  variation_id       :bigint
#
# Indexes
#
#  index_renderables_on_action_id     (action_id)
#  index_renderables_on_variation_id  (variation_id)
#
# Foreign Keys
#
#  fk_rails_...  (action_id => actions.id)
#  fk_rails_...  (variation_id => variations.id)
#

class Renderable < ApplicationRecord
  belongs_to :action
  belongs_to :variation
end
