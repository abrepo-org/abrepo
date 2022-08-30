# == Schema Information
#
# Table name: profiles
#
#  id                      :bigint           not null, primary key
#  company_name            :string
#  description             :string
#  description_source_name :string
#  description_source_url  :string
#  domain                  :string
#  favicon_url             :string
#  logo_url                :string
#  url                     :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  a_id                    :string
#

class Profile < ApplicationRecord
  include PgSearch::Model

  acts_as_taggable_on :industry_tag  # profile.industry_tag_list

  pg_search_scope :search_company_name,
                  against: [:company_name],
                  using: PgSearch.multisearch_options[:using]

  pg_search_scope :search_domain,
                  against: [:domain],
                  using: PgSearch.multisearch_options[:using]

  pg_search_scope :search_description,
                  against: [:description],
                  using: PgSearch.multisearch_options[:using]

  has_many :experiments

  has_and_belongs_to_many :related_companies,
                          class_name: "Profile",
                          join_table: "related_profiles",
                          foreign_key: "profile_id",
                          association_foreign_key: "related_profile_id"

  validates :domain, presence: true, uniqueness: true

  # expvar table display temp attributes
  attribute :expvar_company_name
  attribute :expvar_domain
  attribute :expvar_description

  # stub to reuse same views as variations
  def published?
    return true
  end

  #
  # combo search
  # do this so we can get pg_search_highlight attributes
  #
  def self.search_company(query, profilePolicyScope)

    # build id -> pg_search_highlight maps id => {name, description, domain)
    search_names = self.search_company_name(query)
                     .with_pg_search_rank
                     .with_pg_search_highlight

    search_domains = self.search_domain(query)
                       .with_pg_search_rank
                       .with_pg_search_highlight

    search_descriptions = self.search_description(query)
                            .with_pg_search_rank
                            .with_pg_search_highlight

    names_map = search_names.index_by(&:id)
    domains_map = search_domains.index_by(&:id)
    descriptions_map = search_descriptions.index_by(&:id)

    # get ids, aggregate score, sort
    scores = {}
    search_collect = [
      search_names.pluck(:id, :rank),
      search_domains.pluck(:id, :rank),
      search_descriptions.pluck(:id, :rank)
    ].flatten(1).each do |id, rank|
      scores[id] ||= 0
      scores[id] += rank
    end
    profile_order = scores.sort_by{ |id, rank| -rank }
    profile_order_ids = profile_order.map{ |r| r[0] }

    # filter and then re-order
    #
    # ordinal query breaks when chained on policyScope, so we filter
    # first using scope to get ids, then requery based on policy filtered
    # ids and which can be re-ordered
    #
    profile_ids = profilePolicyScope.where(id: profile_order_ids).pluck(:id).uniq

    #query result profiles (in order)
    profiles = self
                 .where(id: profile_ids)
                 .order(Arel.sql("position(id::text in '#{profile_order_ids.join(',')}')"))

    return profiles, names_map, domains_map, descriptions_map
  end

  def self.build_tag_examples(user, scopedProfile, tags)

    tag_profiles = {}

    tag_group =
      ActsAsTaggableOn::Tagging
        .includes(:tag, :taggable)
        .where(taggable_type: "Profile", taggable_id: scopedProfile.all)
        .group_by{ |tagging| tagging.tag_id }


    tags.each do |tag|
      if tag_group.key?(tag.id)
        tag_profiles[tag.id] = tag_group[tag.id]
                                 .map{ |tag| tag.taggable }
                                 .uniq{|taggable| taggable[:company_name] }[0,3]
      else
        tag_profiles[tag.id] = []
      end
    end

    # Possible cache approach, but query above is actually fast enough
    # where cache overhead might penalize
    #
    # val = Rails.cache
    #           .fetch(
    #             ["#{tag.cache_key_with_version}-#{user && user.moderator?}",
    #              "/profile_build_tag_examples"].join(),
    #             expires_in: 1.day) do
    #  tag_profiles[tag.id] = val
    # end

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
