# == Schema Information
#
# Table name: variations
#
#  id            :bigint           not null, primary key
#  summary_name  :string
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  a_id          :string
#  experiment_id :bigint
#  vendor_id     :string
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
  has_many :actions, -> { distinct }, through: :renderables

  validates :a_id, :experiment_id, :vendor_id, presence: true
end
