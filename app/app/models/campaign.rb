# == Schema Information
#
# Table name: campaigns
#
#  id            :bigint           not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
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
end
