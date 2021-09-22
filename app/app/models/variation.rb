# == Schema Information
#
# Table name: variations
#
#  id            :bigint           not null, primary key
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

class Variation < ApplicationRecord
  include PgSearch::Model

  multisearchable against: [:summary_name],
                  additional_attributes: -> (variation) {{ experiment_id: variation.experiment_id }}

  # TODO: move search to pg_search_documents
  # table to leverage indexing
  pg_search_scope :search_tag,
                  associated_against: {
                    tag: [:name],
                    page_tag: [:name]
                  },
                  using: {
                    tsearch: { prefix: true, dictionary: 'english' }
                  }

  belongs_to :experiment
  has_many :renderables, dependent: :destroy
  has_many :actions, -> { distinct }, through: :renderables

  validates :a_id, :experiment_id, :vendor_id, presence: true

  #expvar table display temp attributes
  attribute :multiple_views
  attribute :is_root

  # variation.tag_list, page_tag_list
  acts_as_taggable_on :tag, :page_tag

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
