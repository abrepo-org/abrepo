# == Schema Information
#
# Table name: profiles
#
#  id           :bigint           not null, primary key
#  company_name :string
#  domain       :string
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  a_id         :string
#

class Profile < ApplicationRecord
  acts_as_taggable_on :industry_tag  # profile.industry_tag_list
  has_many :experiments

  has_and_belongs_to_many :related_companies,
                          class_name: "Profile",
                          join_table: "related_profiles",
                          foreign_key: "profile_id",
                          association_foreign_key: "related_profile_id"

  validates :domain, :a_id, presence: true


  def hostname
    self.url ? URI(self.url).hostname : self.domain
  end

  def as_json(options)
    super(only: [:company_name, :domain])
  end

end
