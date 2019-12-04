require 'test_helper'

class TestModelsControllerTest < ActionDispatch::IntegrationTest
  test "should get test" do
    get test_models_test_url
    assert_response :success
  end

end
