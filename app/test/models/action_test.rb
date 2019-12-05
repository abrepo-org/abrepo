# == Schema Information
#
# Table name: actions
#
#  id         :bigint           not null, primary key
#  selector   :string
#  type       :string
#  url        :string
#  waitfor    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
