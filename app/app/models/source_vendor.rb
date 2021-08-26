# == Schema Information
#
# Table name: source_vendors
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SourceVendor < ApplicationRecord
  has_many :experiments
  validates :name, presence: true, uniqueness: true, allow_nil: false, allow_blank: false
end
