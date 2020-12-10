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
#  a_id       :string
#

require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
