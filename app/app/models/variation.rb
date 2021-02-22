# == Schema Information
#
# Table name: variations
#
#  id            :bigint           not null, primary key
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

class Variation < ApplicationRecord
  belongs_to :experiment
  has_one :vendor

  has_many :renderables, dependent: :destroy
  has_many :actions, -> { distinct }, through: :renderables

  validates :a_id, :experiment_id, :vendor_id, presence: true

  def visibleActions
    visibleActions = { active: [], control: [] }

    self.renderables.where(control: false).each do |renderable |
      unless renderable.action.actionType.nil?
        visibleActions[:active].push(renderable.preExecuteAction)
        visibleActions[:control].push(renderable.controlRenderable.preExecuteAction)
      end
    end

    return visibleActions
  end
end
