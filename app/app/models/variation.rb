# == Schema Information
#
# Table name: variations
#
#  id            :bigint           not null, primary key
#  name          :string
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  experiment_id :bigint
#
# Indexes
#
#  index_variations_on_experiment_id  (experiment_id)
#
# Foreign Keys
#
#  fk_rails_...  (experiment_id => experiments.id)
#

class Variation < ApplicationRecord
  belongs_to :experiment
  has_one :vendor

  has_many :renderables
  has_many :actions, through: :renderables
end
