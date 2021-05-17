# == Schema Information
#
# Table name: diffs
#
#  id                  :bigint           not null, primary key
#  calculated          :json
#  crawlId             :string
#  diffPanel           :string           default("true")
#  diffType            :string
#  newDim              :json
#  origDim             :json
#  selector            :string
#  selectorDisplayName :string
#  summary_added       :string
#  summary_delta       :string
#  summary_removed     :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  a_id                :string
#  group_id            :string
#  renderable_id       :bigint
#
# Indexes
#
#  index_diffs_on_renderable_id  (renderable_id)
#
# Foreign Keys
#
#  fk_rails_...  (renderable_id => renderables.id)
#

class Diff < ApplicationRecord
  belongs_to :renderable
  validates :a_id, :renderable_id, presence: true


  def avgY()

    #if not visible change, set to maxY
    if !(self.newDim['isVisible'] && self.origDim['isVisible'])
      return Float::INFINITY
    end

    #take average or value of y
    newY = self.newDim['boundingBox'] && self.newDim['boundingBox']['rect']['y']
    origY = self.origDim['boundingBox'] && self.origDim['boundingBox']['rect']['y']

    if (newY && origY)
      return (newY + origY) / 2.0
    elsif (newY)
      return newY
    elsif (origY)
      return origY
    end

    return Float::INFINITY

  end

  def as_json
    json = super
    json[:type] = self.diffType
    json
  end
end
