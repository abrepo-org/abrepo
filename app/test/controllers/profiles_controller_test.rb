require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest

  #
  # index
  #

  test "should get index with search query" do
    get profiles_url, params: { query: "Acme" }
    assert_response :success
    assert_not_empty assigns(:profiles)
  end

  test "should get empty index with no results search query" do
    get profiles_url, params: { query: "meowmeow" }
    assert_response :success
    assert_empty assigns(:profiles)
  end

  test "should get index without search query" do
    get profiles_url
    assert_response :success
    assert_not_empty assigns(:profiles)
  end


  test "should filter profiles by tags of variations (note query [])" do
    get profiles_url, params: { query: "[hero]" }
    assert_response :success

    assert_not_empty assigns(:tags)
    assert_empty assigns(:industries)
    assert_not_empty assigns(:profiles)
    assert_match /Beta/, response.body
  end

  test "should filter profiles by industries (note query {})" do
    get profiles_url, params: { query: "{solutions}" }
    assert_response :success

    assert_empty assigns(:tags)
    assert_not_empty assigns(:industries)
    assert_not_empty assigns(:profiles)
    assert_match /Acme Corp/, response.body
  end

  #
  # show
  #

  test "should redirect, adjusting to seo friendly url and show profile" do
    p = profiles(:profile_one)
    pname = p.company_name.parameterize

    get profile_url(p)
    assert_response :redirect
    assert_redirected_to "/profiles/#{p.id}/#{pname}"
    assert_not_nil assigns(:profile)
  end


  test "should raise not found for invalid profile" do
    assert_raises(ActionController::RoutingError) do
      get profile_url(id: "invalid_id")
    end
  end


  test "should not show empty profile for non-moderators" do
    skip "skip pending login/logout tests"
    log_out(@user) # Assuming a helper method to log out
    get profile_url(@profile)
    assert_raises(ActionController::RoutingError) do
      get profile_url(@profile)
    end
  end

  test "should be composed of partial response" do
    get profiles_url
    assert_response :success
    assert_template partial: '_profile_cards'
  end
end
