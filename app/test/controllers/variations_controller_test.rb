require "test_helper"

class VariationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_one)
    @variation = variations(:variation_one)
  end

  #
  # show
  #

  test "should get show" do
    vname = @variation.summary_name.parameterize
    get variation_url(@variation)
    assert_response :redirect
    assert_redirected_to "/variations/#{@variation.id}/#{vname}"
  end

  test "should redirect to slug if name does not match" do
    vname = @variation.summary_name.parameterize
    get variation_url(@variation, name: "wrong_slug")
    assert_response :redirect
    assert_redirected_to "/variations/#{@variation.id}/#{vname}"
  end

  test "should raise not found for non-existent variation" do
    assert_raises(ActionController::RoutingError) do
      get variation_url(id: 99999)
    end
  end

  #
  # update
  #

  test "should update variation when authenticated" do
    sign_in @user
    patch variation_url(@variation), params: { variation: { published: true } }
    assert_redirected_to imports_path
    @variation.reload
    assert @variation.published
  end

  test "should not update variation when not authenticated" do
    variation = variations(:variation_two)
    sign_out @user
    patch variation_url(variation), params: { variation: { published: true } }
    assert_redirected_to new_user_session_path
    variation.reload
    assert_not variation.published
  end

  test "should handle unauthorized updates gracefully" do
    sign_in users(:user_two) # not moderator
    patch variation_url(@variation), params: { variation: { published: true } }
    assert_redirected_to profiles_path
  end


end
