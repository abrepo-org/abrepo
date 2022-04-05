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

class Variation < ApplicationRecord
  include Obfuscatable
  include PgSearch::Model

  multisearchable against: [:summary_name, :tag_list, :page_tag_list],
                  #against: [:summary_name],
                  additional_attributes: -> (variation) {{ experiment_id: variation.experiment_id }}

  pg_search_scope :search_tag,
                  associated_against: {
                    tag: [:name],
                    page_tag: [:name]
                  },
                  using: {
                    tsearch: { prefix: true, dictionary: 'english' }
                  }

  belongs_to :experiment, touch: true # expvar cache update
  has_many :renderables, dependent: :destroy
  has_many :actions, -> { distinct }, through: :renderables

  has_many :user_saved_variations, dependent: :destroy
  has_many :users, through: :user_saved_variations

  validates :a_id, :experiment_id, :vendor_id, presence: true

  obfuscatable attributes: [:summary_name, :url], dependent: :experiment

  #expvar table display temp attributes
  attribute :multiple_views
  attribute :is_root

  # variation.tag_list, page_tag_list
  acts_as_taggable_on :tag, :page_tag

  def self.build_tag_examples(user, scopedVariation, tags)

    tag_variations = {}

    tags.each do |tag|
      val = Rails.cache
              .fetch(
                ["#{tag.cache_key_with_version}-#{user && user.moderator?}",
                 "/variation_build_tag_examples"
                ].join(),
                expires_in: 1.day) do

        variations = scopedVariation.tagged_with(tag.name)
                       .select('DISTINCT ON (summary_name) variations.summary_name')
                       .select(:id, :summary_name)
                       .limit(3)

        variations.map{ |v| {id: v.id, summary_name: v.summary_name } }
      end

      tag_variations[tag.id] = val
    end

    tag_variations
  end

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
