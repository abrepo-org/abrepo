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
  belongs_to :experiment
  validates :a_id, :experiment_id, presence: true
end
