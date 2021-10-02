# == Schema Information
#
# Table name: campaigns
#
#  id            :bigint           not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  a_id          :string
#  experiment_id :bigint
#  vendor_id     :string
#
# Indexes
#
#  index_campaigns_on_experiment_id  (experiment_id)
#
# Foreign Keys
#
#  fk_rails_...  (experiment_id => experiments.id)
#


class Campaign < ApplicationRecord
  include PgSearch::Model
  #
  # Exlcude campaign.name from search corpus since info is currently
  # not being displayed (user can't discern relevance of search result)
  #
  # NB: PgSearch::Document.where(searchable_type: "Campaign").delete_all
  #
  #
  # multisearchable against: [:name],
  #                 additional_attributes: -> (campaign) { { experiment_id: campaign.experiment_id } }

  belongs_to :experiment
  validates :a_id, :experiment_id, :vendor_id, presence: true
end
