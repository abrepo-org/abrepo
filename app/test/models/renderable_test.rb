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

require 'test_helper'

class RenderableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
