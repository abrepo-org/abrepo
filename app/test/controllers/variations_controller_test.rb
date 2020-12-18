require "test_helper"

class VariationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get variations_show_url
    assert_response :success
  end
end
