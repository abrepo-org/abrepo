class TestModelsController < ApplicationController

  def clear
=begin
       rake db:purge
       rake db:migrate

# guess the phases would be 
1. profile
2. E, VCA
3. Action, Renderables, Diffs
4. Vendor if neceessayr

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

    #Diff - based off single renderable (control is implied)
    @diff1 = Diff.create(change: "ADDED",
                         selector: ".test",
                         visible: true,
                         boundingBox: {
                           rect: {'x': 1}
                           #renderLayer: active #what is this again
                         },
                         calculated: {
                           text: ['count': 1, 'added':true, value: "hi"]
                         },
                         renderable: @renderable1);

    p @diff1.boundingBox
    x= @diff1.boundingBox
    p x['rect']
    # what if need to edit stuff? Or resubmit? - i guess this would be PATCH route
    # to update the individual model

    p @renderable1.diffs

    # association tests

    respond_to do |format|
      format.html
      #format.html { render plain: "OK" }
    end

  end
end
