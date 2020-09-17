# == Schema Information
#
# Table name: actions
#
#  id         :bigint           not null, primary key
#  crawlID    :string
#  selector   :string
#  type       :string
#  url        :string
#  waitfor    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Action < ApplicationRecord
  has_many :renderables
  has_many :variations, through: :renderables
end
