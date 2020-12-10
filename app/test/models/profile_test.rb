# == Schema Information
#
# Table name: profiles
#
#  id           :bigint           not null, primary key
#  company_name :string
#  domain       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  a_id         :string
#

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
