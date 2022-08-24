# == Schema Information
#
# Table name: profiles
#
#  id                      :bigint           not null, primary key
#  company_name            :string
#  description             :string
#  description_source_name :string
#  description_source_url  :string
#  domain                  :string
#  favicon_url             :string
#  logo_url                :string
#  url                     :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  a_id                    :string
#

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
