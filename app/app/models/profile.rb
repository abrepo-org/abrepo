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

  pg_search_scope :search_company,
                  against: [
                    [:company_name, 'A'],
                    [:domain, 'B'],
                    [:description, 'C']
                  ],
                  using: { tsearch: { prefix: true, dictionary: 'english' } }

  pg_search_scope :search_industry_and_company,
                  associated_against: {
                    industry_tag: [:name],
                  },
                  against: [
                    [:company_name, 'A'],
                    # ignore description now until we can show query
                    # in description snippet - otherwise can't show relevance
                    # in search results to user
                    # [:description, 'B'],
                    [:domain, 'B']
                  ],
                  using: { tsearch: { prefix: true, dictionary: 'english' } }

  has_many :experiments

  has_and_belongs_to_many :related_companies,
                          class_name: "Profile",
                          join_table: "related_profiles",
                          foreign_key: "profile_id",
                          association_foreign_key: "related_profile_id"

  validates :domain, presence: true, uniqueness: true


  def self.build_tag_examples(user, scopedExperiment, tags)

    tag_profiles = {}

    tags.each do |tag|
      val = Rails.cache
              .fetch(
                ["#{tag.cache_key_with_version}-#{user && user.moderator?}",
                 "/profile_build_tag_examples"].join(),
                expires_in: 1.day) do

        profiles = self.tagged_with(tag.name)
                     .select('DISTINCT ON (company_name) profiles.company_name')
                     .select(:id, :company_name)
                     .includes(:experiments)
                     .where.not(experiments: {profile_id: nil}) #ignore empty profiles
                     .where(experiments: scopedExperiment.all)  #experiments must be authorized
                     .limit(3)

        profiles.map{ |v| {id: v.id, company_name: v.company_name } }
      end

      tag_profiles[tag.id] = val
    end

    tag_profiles
  end

  def get_related_companies(num)

    results = self.active_related_companies(num).collect do |company|
      {type: :active, company: company}
    end

    results += self.inactive_related_companies( num - results.length )
                 .collect do |company|
      {type: :inactive, company: company}
    end

    return results
  end

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
