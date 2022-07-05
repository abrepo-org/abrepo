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
#  viewMode            :string
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
  include Obfuscatable
  belongs_to :renderable
  delegate :variation, to: :renderable, :allow_nil => true

  obfuscatable attributes: [:summary_added, :summary_removed, :summary_delta],
               dependent: :variation
  validates :a_id, :renderable_id, presence: true

  def randomizeBoundingBox
    ['newDim', 'origDim'].each do |dim|
      if self[dim]

        x = rand * self[dim]['pageDims']['screenshot_dimensions']['width']
        y = rand * self[dim]['pageDims']['screenshot_dimensions']['height']

        if self[dim]['boundingBox']
          self[dim]['boundingBox']['rect']['x'] = x
          self[dim]['boundingBox']['rect']['y'] = y
          self[dim]['boundingBox']['rect']['left'] = 0
          self[dim]['boundingBox']['rect']['top'] = 0
          self[dim]['boundingBox']['rect']['bottom'] = 0
          self[dim]['boundingBox']['rect']['right'] = 0
        end
      end
    end
  end

  def removeDetails
    self.calculated = {}
    self.selector = nil
    self.selectorDisplayName = nil
  end

  def isNotVisible()
    return !(self.newDim['isVisible'] && self.origDim['isVisible'])
  end

  def avgY()

    #if not visible change, set to maxY
    if self.isNotVisible
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
