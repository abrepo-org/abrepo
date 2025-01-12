require "test_helper"
require "minitest/mock"

class UserSavedVariationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_one)
    sign_in @user
  end

  def test_create_saves_new_variation
    variation = variations(:variation_three) # not already set via fixture

    assert_difference '@user.user_saved_variations.count', 1 do
      post saved_path(id: variation.id), as: :json
    end

    assert_response :success
    json_response = JSON.parse(@response.body)
    assert json_response['saved']
  end

  def test_create_toggles_deleted_status
    existing_variation = @user.user_saved_variations.find_by_variation_id(variations(:variation_one).id)

    assert_no_difference '@user.user_saved_variations.count' do
      post saved_path(id: existing_variation.variation_id), as: :json
    end

    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_not json_response['saved']
    existing_variation.reload
    assert existing_variation.deleted?
  end

  def test_index_returns_user_saved_variations
    get saved_path

    assert_response :success
    assert_not_nil assigns(:experiments)
    assert_not_nil assigns(:pagy)
    assert_not_nil assigns(:top_profiles)
    assert_not_nil assigns(:top_industries)
    assert_not_nil assigns(:user_saved_variations)
  end
end
