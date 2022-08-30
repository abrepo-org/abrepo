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

  pg_search_scope :search_summary_name,
                  against: [:summary_name],
                  using: PgSearch.multisearch_options[:using]

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

    tag_group =
      ActsAsTaggableOn::Tagging
      .includes(:tag, :taggable)
      .where(taggable_type: "Variation", taggable_id: scopedVariation.all)
      .group_by{ |tagging| tagging.tag_id }


    tags.each do |tag|
      if tag_group.key?(tag.id)
        tag_variations[tag.id] = tag_group[tag.id]
                                   .map{ |tag| tag.taggable }
                                   .filter{ |taggable| !taggable[:summary_name].blank? }
                                   .uniq{|taggable| taggable[:summary_name] }[0,3]
      else
        tag_variations[tag.id] = []
      end
    end

    # Possible cache approach, but query above is actually fast enough
    # where cache overhead might penalize
    #
    # val = Rails.cache
    #            .fetch(
    #             ["#{tag.cache_key_with_version}-#{user && user.moderator?}",
    #              "/variation_build_tag_examples"
    #             ].join(),
    #             expires_in: 1.day) do
    # tag_variations[tag.id] = val

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
