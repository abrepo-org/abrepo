require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest

  test "should return 404 for missing page" do
    get '/abracadabra'
    assert_response :missing
    assert_template 'errors/404'
  end

  test "should return 500 for internal server error" do
    get '/500'
    assert_response :internal_server_error
    assert_template 'errors/500'
  end

  test "should render 422 for for unauthorized action" do
    skip "TODO"
    # post '/imports'
    # assert_template 'errors/422'
  end

end
