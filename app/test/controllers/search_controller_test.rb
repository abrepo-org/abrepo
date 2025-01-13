require "test_helper"
require "minitest/mock"

class SearchControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  test "index action responds successfully" do
    get search_path
    assert_response :success
  end

  test "index assigns variables correctly" do
    get search_path, params: { query: '[cta]' }
    assert_response :success
    assert assigns(:query)
    assert assigns(:tags)
    assert assigns(:industries)
    assert assigns(:experiments)
    assert assigns(:profiles)
    assert assigns(:variations)
    assert assigns(:top_profiles)
    assert assigns(:top_industries)
  end

  test "search handles renders results partial on params[:partial]" do
    get search_path, params: { query: 'hero', partial: true }
    assert_response :success
    assert_template partial: "_results"
  end

  test "search handles renders full results with no params[:partial] and query returns profiles" do
    get search_path, params: { query: 'tech {food}' }
    assert_response :success
    assert_template partial: "_results"
    assert assigns(:profiles).first.company_name.include?("Beta")
    assert_empty assigns(:variations)
  end

  test "search handles renders full results query matches only experiments & variations" do
    get search_path, params: { query: 'Summary' }
    assert_response :success
    assert_template partial: "_results"
    assert_empty assigns(:profiles)
    assert_not_empty assigns(:experiments)
    assert_not_empty assigns(:variations)
  end

  test "search index featured experiments" do
    get search_path
    assert_response :success
    assert_not_empty assigns(:featured_experiments)
  end

  test "failed search has no pagination on experiments" do
    get search_path, params: { query: 'dfasdfasdf'}
    assert_nil assigns(:pagy)
    assert assigns(:experiments)
  end

  test "has pagination on valid search" do
    get search_path, params: { query: '[cta]'}
    assert_not_nil assigns(:pagy)
    assert assigns(:experiments)
  end

end
