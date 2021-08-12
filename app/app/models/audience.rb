# == Schema Information
#
# Table name: audiences
#
#  id            :bigint           not null, primary key
#  description   :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  experiment_id :bigint
#
# Indexes
#
#  index_audiences_on_experiment_id  (experiment_id)
#
# Foreign Keys
#
#  fk_rails_...  (experiment_id => experiments.id)
#

class Audience < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :description],
                  additional_attributes: -> (audience) { { experiment_id: audience.experiment_id } }

  belongs_to :experiment
end
