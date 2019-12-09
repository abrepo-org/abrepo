class TestModelsController < ApplicationController

  def clear
=begin
       rake db:purge
       rake db:migrate


=end
  end

  def test
    crawlId = "5dca06c77e4e6c003e5364ba"
    url = "https://www.optimizely.com"
    domain = "optimizely.com"

    @profile = Profile.create(company_name: "Optimizely",
                              domain: domain)

    @experiment = Experiment.create(:name => "Something Experiment Name",
                                    crawlID: crawlId,
                                    domain: domain,
                                    profile: @profile)

    @campaign = Campaign.create(:name => "campaign name", :experiment => @experiment)

    @audience = Audience.create(name: "audience name",
                                description: "some kind of audience description",
                                experiment: @experiment)

    @variation1 = Variation.create(name: "variation name",
                                   url: url,
                                   experiment: @experiment)

    #necessary?
    # do want some ABType indication, but can put on experiment.
    @vendor = Vendor.create(campaignID: "11709602200",
                            experimentID: "11709602200",
                            variationID: "11709602200",
                            variantID: "5dca109b4a47f400100c1e49",
                            viewID: "11709602200",
                            name: "Vendor Name",
                            experiment: @experiment,
                            variation: @variation1)


    @action = Action.create(selector: "#someSelector",
                            type: nil,
                            crawlID: crawlId,
                            url: url,
                            waitfor: 1000)


    @controlRenderable = Renderable.create(domain: domain,
                                           renderedTitle: "Page Title",
                                           renderedURL: url,
                                           control: true,
                                           screenshotFilename: 'https://us-east-2a.control.filename.png',
                                           action: @action)

    @renderable1 = Renderable.create(domain: domain,
                                    renderedTitle: "Page Title",
                                    renderedURL: url,
                                    control: false,
                                    screenshotFilename: 'https://us-east-2a.something.filename.png',
                                    action: @action,
                                    variation: @variation1,
                                    controlRenderable: @controlRenderable)

    p @renderable1.controlRenderable
    p @controlRenderable.controlRenderable
    #Diff (TODO)
    #can models store json objects - probably easiest
    #diff belongs_to renderable
    #renderbale has_many diffs
    # @diff1 = Diff.create(type: "ADDED",
    #                      selector: ".test",
    #                      visible: true, #false,
    #                      boundingBox: {
    #                        #rect: x,y,z.... #rect Object?
    #                        visible: true,
    #                        renderLayer: active || false #what is this again
    #                      },
    #                      calculated: {
    #                        #text, tag, css: [ { count:1, added/removed/changed: true, value: somei}]
    #                      }
    #                      renderable: @renderable1);


    # what if need to edit stuff? Or resubmit? - i guess this would be PATCH route
    # to update the individual model

    # association tests

    respond_to do |format|
      format.html
      #format.html { render plain: "OK" }
    end

  end
end
