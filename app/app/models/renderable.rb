# == Schema Information
#
# Table name: renderables
#
#  id                 :bigint           not null, primary key
#  domain             :string
#  renderedTitle      :string
#  renderedURL        :string
#  screenshotFilename :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Renderable < ApplicationRecord
  has_many :variations, :through => :actions
end
