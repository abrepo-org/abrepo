require 'test_helper'

class HealthcheckControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    get healthcheck_path
    assert_response :success
    assert_match /pong/, @response.body
  end

end
