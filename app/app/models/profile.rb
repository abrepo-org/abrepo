# == Schema Information
#
# Table name: profiles
#
#  id           :bigint           not null, primary key
#  company_name :string
#  description  :string
#  domain       :string
#  favicon_url  :string
#  logo_url     :string
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  a_id         :string
#

class Profile < ApplicationRecord
  include PgSearch::Model

  acts_as_taggable_on :industry_tag  # profile.industry_tag_list

  pg_search_scope :search_industry_tag,
                  associated_against: { industry_tag: [:name] },
                  using: { tsearch: { prefix: true, dictionary: 'english' } }
  pg_search_scope :search_company_name,
                  against: :company_name,
                  using: { tsearch: { prefix: true, dictionary: 'english' } }

  has_many :experiments

  has_and_belongs_to_many :related_companies,
                          class_name: "Profile",
                          join_table: "related_profiles",
                          foreign_key: "profile_id",
                          association_foreign_key: "related_profile_id"

  validates :domain, :a_id, presence: true


  def active_related_companies(num)
    self.related_companies.includes(:experiments)
      .where.not(experiments: {profile_id:nil})
      .limit(num)
  end

  def inactive_related_companies(num)
    self.related_companies.includes(:experiments)
      .where(experiments: {profile_id:nil})
      .limit(num)
  end

  def hostname
    self.url ? URI(self.url).hostname : self.domain
  end

  def as_json(options)
    super(only: [:company_name, :domain])
  end

end
