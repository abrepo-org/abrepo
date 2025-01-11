require "test_helper"
require "minitest/mock"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers


  def setup
    @user = users(:user_one)
    sign_in @user
  end

  test "should get index" do
    get home_path
    assert_response :success
    assert_not_nil assigns(:experiments)
    assert_not_nil assigns(:variations)
    assert_not_nil assigns(:top_profiles)
    assert_not_nil assigns(:top_industries)
    assert_not_nil assigns(:featured_experiments)
    assert_not_nil assigns(:user_saved_variations)
  end


  test "should paginate experiments" do
    get home_path, params: { page: 2 }
    assert_response :success
    assert_not_nil assigns(:pagy)
  end


  test "should obfuscate experiments if not subscribed and on page > 2" do
    skip "cancelled obfuscation for now"
    sign_out @user
    get home_path, params: { page: 3 }
    assert_response :success
    assert_not_nil assigns(:experiments)
    assert assigns(:experiments).count < Experiment.count
  end

  test "should include call to Sidebar.top_profiles method" do
    mock = Minitest::Mock.new
    mock.expect(:call, profiles)

    Sidebar.stub(:top_profiles, mock) do
      get home_path
      assert_response :success
      assert_not_nil assigns(:top_profiles)
    end

    assert mock.verify # Ensure the method was called as expected
  end

  test "should include call to Sidebar.top_industries method" do
    mock = Minitest::Mock.new
    tags = ActsAsTaggableOn::Tag.all
    mock.expect(:call, tags[2...4])

    Sidebar.stub(:top_industries, mock) do
      get home_path
      assert_response :success
      assert_not_nil assigns(:top_industries)
    end

    assert mock.verify # Ensure the method was called as expected

  end

  test "should calculate featured experiments" do
    mock = Minitest::Mock.new
    # NB: mock.expect(:method_name, return_value, [arguments]).
    mock.expect(:call, [], [5])

    Experiment.stub(:calcRank, mock) do
      get home_path
      assert_response :success
      assert_not_nil assigns(:featured_experiments)
      assert assigns(:featured_experiments).length <= 5
    end

    assert mock.verify
  end
end
