require "test_helper"

class SitemapControllerTest < ActionDispatch::IntegrationTest

  test "renders correct template" do
    get "/sitemap.xml"
    assert_template 'sitemap/index'
  end

  test "should get sitemap in xml" do
    get "/sitemap.xml"
    assert_response :success
    assert_match /<url>/, @response.body
    assert_equal 'application/xml; charset=utf-8', @response.content_type
  end

  test "assigns profiles" do
    get "/sitemap.xml"
    assert assigns(:profiles).present?
  end

  test "assigns variations" do
    get "/sitemap.xml"
    assert assigns(:variations).present?
  end
end
