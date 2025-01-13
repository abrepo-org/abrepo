require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest

  test "should get index with no query" do
    get tags_path
    assert_response :success
    assert assigns(:tags).length > 0
  end

  test "should filter index with query" do
    get tags_path, params: { query: "cta" }
    assert_response :success
    assert_equal 1, assigns(:tags).length
    assert_equal "cta", assigns(:tags).first.name
  end

  test "can respond with json format" do
    get tags_path, params: { partial: true, format: :json }
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_includes json_response['results'].map { |tag| tag['name'] }, "cta"
    assert_includes json_response['results'].map { |tag| tag['name'] }, "hero"
    assert_equal 2, json_response['total']
  end

  test "should render partial if requested" do
    get tags_path, params: { partial: true }
    assert_response :success
    assert_template partial: '_tags'
  end

end
