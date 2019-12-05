class TestModelsController < ApplicationController

  def clear
=begin
       rake db:purge
       rake db:migrate
=end
  end

  def test
    url = "https://www.optimizely.com"
    domain = "optimizely.com"

    @profile = Profile.create(company_name: "Optimizely",
                              domain: domain)

    @experiment = Experiment.create(:name => "Something Experiment Name",
                                    crawlID: "5dca06c77e4e6c003e5364ba",
                                    domain: domain,
                                    profile: @profile)

    @campaign = Campaign.create(:name => "campaign name", :experiment => @experiment)

    @audience = Audience.create(name: "audience name",
                                description: "some kind of audience description",
                                experiment: @experiment)


    @variation0 = Variation.create(name: "variation name control",
                                   control: true,
                                   url: url,
                                   experiment: @experiment)

    @variation1 = Variation.create(name: "variation name",
                                   control: false,
                                   url: url,
                                   experiment: @experiment)

    @vendor = Vendor.create(campaignID: "11709602200",
                            experimentID: "11709602200",
                            variationID: "11709602200",
                            variantID: "5dca109b4a47f400100c1e49",
                            viewID: "11709602200",
                            name: "Vendor Name",
                            experiment: @experiment,
                            variation: @variation0)

    @action = Action.create(selector: "#someSelector",
                            type: nil,
                            url: url,
                            waitfor: 1000)

    @renderable = Renderable.create(domain: domain,
                                    renderedTitle: "Page Title",
                                    renderedURL: url,
                                    screenshotFilename: 'https://us-east-2a.something.filename.png',
                                    action: @action,
                                    variation: @variation0)


    # association tests

    respond_to do |format|
      format.html
      #format.html { render plain: "OK" }
    end

  end
end
