# == Schema Information
#
# Table name: experiments
#
#  id           :bigint           not null, primary key
#  crawlId      :string
#  domain       :string
#  summary_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  a_id         :string
#  profile_id   :bigint
#  vendor_id    :string
#
# Indexes
#
#  index_experiments_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#

class Experiment < ApplicationRecord
  acts_as_taggable_on :variation_tag, :page_tag  # experiment.variation_tag_list

  belongs_to :profile
  has_many :variations, dependent: :destroy
  has_one :vendor, dependent: :destroy
  has_one :campaign, dependent: :destroy
  has_one :audience, dependent: :destroy

  validates :crawlId, :domain, :a_id, :profile_id, :vendor_id, presence: true
end
