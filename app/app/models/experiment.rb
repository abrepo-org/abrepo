# == Schema Information
#
# Table name: experiments
#
#  id               :bigint           not null, primary key
#  audience_name    :string
#  calcscore        :float            default(0.0)
#  crawlId          :string
#  domain           :string
#  published        :boolean          default(FALSE)
#  summary_name     :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  a_id             :string
#  profile_id       :bigint
#  source_vendor_id :bigint
#  vendor_id        :string
#
# Indexes
#
#  index_experiments_on_profile_id        (profile_id)
#  index_experiments_on_source_vendor_id  (source_vendor_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (source_vendor_id => source_vendors.id)
#

class Experiment < ApplicationRecord
  include Obfuscatable
  include PgSearch::Model

  multisearchable against: [:summary_name, :audience_name],
                  additional_attributes: -> (experiment) { { experiment_id: experiment.id } }

  belongs_to :profile
  belongs_to :source_vendor
  has_many :variations, dependent: :destroy
  has_one :campaign, dependent: :destroy

  obfuscatable attributes: [:summary_name, :domain, :audience_name]
  validates :crawlId, :domain, :a_id, :profile_id, :vendor_id, presence: true

  def audience
    multiple_name = "Targeting: Various"

    if self.audience_name.blank?
      return multiple_name unless self.obfuscated
      return obfuscate_text(multiple_name)
    end

    return self.audience_name
  end

  def tags
    self.variations.map{ |v| v.tag + v.page_tag}
      .flatten
      .uniq
      .sort
  end

  # calculated score for each experiment based on avg number of diffs
  # used at import time; provides numerator score used against decay (calc in db)
  def score

    numDiffs = self.variations.joins(renderables: :diffs).group(:id).count
    avgDiffs = [numDiffs.values.sum.to_f / [numDiffs.size, 1].max, 1].max

    numRenderables = self.variations.joins(:renderables).group(:id).count
    avgRenderables = [numRenderables.values.sum.to_f / [numRenderables.size, 1].max, 1].max

    Distribution::Poisson.pdf(3, avgDiffs / avgRenderables).floor(5)

  end


  def self.calcRank(num)

    select("*, (experiments.calcscore / (POW(( ( (SELECT EXTRACT(EPOCH FROM CURRENT_TIMESTAMP(0))) - (SELECT EXTRACT(EPOCH FROM experiments.created_at)) ) / 3600) + 2, 1.8))) as calcscoreRank")
      .order('calcscoreRank desc')
      .limit(num)
  end

end
