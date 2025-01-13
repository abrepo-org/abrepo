require "test_helper"

class LegalControllerTest < ActionDispatch::IntegrationTest
  test "should get privacy" do
    get privacy_policy_path
    assert_response :success
  end

  test "should get tos" do
    get terms_of_service_path
    assert_response :success
  end

  test "should get dmca" do
    get dmca_path
    assert_response :success
  end

end
