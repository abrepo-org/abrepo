require "test_helper"

class IndustriesControllerTest < ActionDispatch::IntegrationTest

  test 'should get index with no query' do
    get industries_url
    assert_response :success
    assert_not_nil assigns(:industries)
  end

  test 'should get index with valid query' do
    @tag = ActsAsTaggableOn::Tag.find_by_name("food")
    get industries_url, params: { query: 'food' }
    assert_response :success
    assert_not_nil assigns(:industries)
    assert_equal @tag.name, assigns(:industries).first.name
    assert_equal assigns(:industries).first, @tag
    assert_empty assigns(:industries).select { |t| t.name == 'Healthcare' }
  end

  test 'should return json on autocomplete' do
    get industries_url, params: { partial: true, query: 'tech' }, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response['results'].any? { |result| result['name'] == 'tech' }
    assert_equal 3, json_response['total'] # 3 other industry tag fixtures
  end

  test 'should render partial for autocomplete' do
    get industries_url, params: { partial: true, query: 'tech' }
    assert_template '_industries'
  end


  test 'should calculate recency hash' do
    get industries_url
    assert_response :success
    assert_not_nil assigns(:recency_hash_by_id)

    # industry tags
    @tags = ActsAsTaggableOn::Tag.all
    assert assigns(:recency_hash_by_id).key?(@tags[2].id)
    assert assigns(:recency_hash_by_id).key?(@tags[3].id)
    assert assigns(:recency_hash_by_id).key?(@tags[4].id)
  end
end
