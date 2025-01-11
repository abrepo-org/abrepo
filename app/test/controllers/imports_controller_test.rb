require 'test_helper'

class ImportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user_moderator = users(:user_one)
    @user_vanilla = users(:user_two)
  end

  test "should get index" do
    sign_in @user_moderator
    get imports_url
    assert_response :success
    assert_not_nil assigns(:experiments)
  end

  test "should not authorize user for import - http 302 redirect" do
    sign_in @user_vanilla
    post imports_url,
         params: { input: valid_import_params }
    assert_redirected_to profiles_path
  end

  test "should not authorize user for import - json 401" do
    sign_in @user_vanilla
    post imports_url, params: { input: valid_import_params },
         headers: { 'Accept' => 'application/json',
                    'Content-Type' => 'application/json' }
    assert_response :unauthorized
  end


  test "should create 2 Profiles: import Profile with additional profile stub of related_coompanies" do
    sign_in @user_moderator
    assert_difference 'Profile.count', 2 do
      post imports_url,
           params: { input: valid_import_params }.to_json,
           headers: {  'Accept' => 'application/json',
                       'Content-Type' => 'application/json' }
    end

    assert_response :success
    assert JSON.parse(@response.body)["success"]
  end

  test "should not create import with invalid data" do
    sign_in @user_moderator
    assert_no_difference 'Profile.count' do
      post imports_url,
           params: { input: invalid_import_params }.to_json,
           headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    end
    assert_response :unprocessable_entity
  end





  def valid_import_params
    {
      group: {
        profile: {
          _id: "some_id",
          domain: "example.com",
          company_name: "Example Inc.",
          url: "http://example.com",
          description: "Some description",
          related_companies: [
            {
              domain: "another.com",
              company_name: "Another Inc."
            }
          ]
        },
        experiment: {
          experiment_id: "experiment_id",
          _id: "experiment_id",
          crawlId: "crawl_id",
          published: true,
          summary_name: "Experiment Summary",
          audienceName: "Audience Name",
          domain: "example.com"
        },
        campaign: {
          campaign_id: "campaign_id",
          _id: "campaign_id",
          name: "Campaign Name"
        },
        variation: {
          _id: "variation_id",
          variation_id: "variation_id",
          summary_name: "Variation Summary",
          crawlURL: "http://example.com/variation",
          published: false,
          audienceName: "Variation Audience",
          tags: {
            tag_list: ["tag1", "tag2"],
            page_tag_list: ["page_tag1", "page_tag2"]
          }
        },
        tags: {
          industry_tag_list: ["tech", "software"]
        }
      },
      action_id: "action_id",
      activeAction: {
        type: "click",
        selector: "button#submit",
        url: "http://example.com",
        selectorDisplayName: "Submit Button",
        description: "Clicks the submit button"
      },
      base_renderable: {
        _id: "base_renderable_id",
        domain: "example.com",
        renderedTitle: "Base Renderable Title",
        renderedURL: "http://example.com/base",
        preExecuteAction: "someAction",
        screenshotDimensions: {
          width: 800,
          height: 600
        },
        screenshotFilename: "base_screenshot.png"
      },
      active_renderable: {
        _id: "active_renderable_id",
        domain: "example.com",
        renderedTitle: "Active Renderable Title",
        renderedURL: "http://example.com/active",
        preExecuteAction: "activeAction",
        screenshotDimensions: {
          width: 800,
          height: 600
        },
        screenshotFilename: "active_screenshot.png"
      },
      diffs: []
    }
  end


  def invalid_import_params
    {
      group: {
        profile: {
          _id: nil,
          domain: nil,
          related_companies: []
        }
      }
    }
  end
end
