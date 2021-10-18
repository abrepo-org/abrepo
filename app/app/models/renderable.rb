# == Schema Information
#
# Table name: renderables
#
#  id                 :bigint           not null, primary key
#  control            :boolean
#  crawlId            :string
#  domain             :string
#  preExecuteAction   :json
#  renderedTitle      :string
#  renderedURL        :string
#  screenshotFilename :string
#  screenshotHeight   :integer
#  screenshotWidth    :integer
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

#
# preExecuteAction: this is the action state captured immediately
# prior to executing the action. Action selector bbox (should) equal
# to nullAction which we collect in visibleActions to display what
# actions are available
#
class Renderable < ApplicationRecord
  include Obfuscatable

  belongs_to :action
  belongs_to :variation
  belongs_to :controlRenderable, class_name: "Renderable",
             foreign_key: :renderable_id, optional: true
  has_many :diffs, dependent: :destroy

  obfuscatable attributes: [:renderedURL], dependent: :variation

  validates :a_id, :action_id, :variation_id, presence: true
  validates :control, inclusion: [true, false]


  def screenshot()
    "#{ENV['FILE_HOST']}#{self.screenshotFilename}"
  end

  def sortedDiffs()

    # NB default sort descending - highest avgY, but we want ordered asc (low to high)
    # diffs are obfuscated here if parent variation is obfuscated as well
    diffs = self.diffs
              .sort{ |d| d.avgY }
              .each{ |d|

                     d.obfuscate

                     if d.obfuscated?
                       d.randomizeBoundingBox
                       d.removeDetails
                     end
              }
              .reverse
              .map{ |d| d.attributes.except("a_id", "renderable_id", "created_at", "updated_at") }


    return diffs
  end

  def preExecuteAction
    action = self[:preExecuteAction].as_json({except: ["_id", "createdAt", "updatedAt", "__v"]})
    action["id"] = self.action.id if action
    action["actionType"] = self[:preExecuteAction]['type'] if action
    return action
  end

  #TODO:
  #https://thoughtbot.com/blog/better-serialization-less-as-json
  #

  def to_render(options = {})

    as_json({methods: [:screenshot, :sortedDiffs, :preExecuteAction],
             except: [:id, :a_id, :variation_id, :renderable_id, :action_id,
                      :updated_at, :created_at]}
              .merge(options))

  end

end
