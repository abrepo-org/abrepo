class ImportsController < ApplicationController
  protect_from_forgery except: :create

  def test
    render json: params
  end

  #
  #curl -i -H "Content-Type: application/json" -X POST localhost/imports/ -d '{"test":"123"}'
  #
  # a_id and/or content differences should trigger create -- but not
  # sure if entirely desirable

  def create
    #
    # GROUP
    #
    input = params['input']
    group = input['group']

    profile = group['profile']
    @profile = Profile.where(a_id: profile['_id'], domain: profile['domain'])
                 .order(id: :desc)
                 .first_or_create(company_name: profile['company_name'])


    #
    # EXPERIMENT
    #

    experiment = group['experiment']
    @experiment = Experiment.where(vendor_id: experiment['experiment_id'],
                                   a_id: experiment['_id'])
                    .order(id: :desc)
                    .first_or_create(crawlId: experiment['crawlId'],
                                     domain: experiment['domain'],
                                     summary_name: experiment['summary_name'],
                                     profile: @profile)

    @audience = Audience.where(name: experiment['audienceName'],
                               experiment: @experiment)
                  .order(id: :desc)
                  .first_or_create

    campaign = group['campaign']
    @campaign = Campaign.where(vendor_id: campaign['campaign_id'],
                               a_id: campaign['_id'])
                  .order(id: :desc)
                  .first_or_create(name: campaign['name'],
                                   experiment: @experiment)


    #
    # VARIATION
    # TODO: add crawlId: variation['crawlId'],
    variation = group['variation']
    @variation = Variation.where(a_id: variation['_id'],
                                 vendor_id: variation['variation_id'])
                   .order(id: :desc)
                   .first_or_create(summary_name: variation['summary_name'],
                                    url: variation['crawlURL'],
                                    experiment: @experiment)

    #Aciton, Renderable, Diffs - pegged to Variation and crawlId
    crawlId = variation['crawlId']

    #
    #'active' ACTION
    #
    action_id = input['action_id']
    activeAction = input['renderables']['actions']
                     .select { |action| action['_id'] == action_id }
                     .first

    @action = Action.where(type: activeAction['type'],
                           selector: activeAction['selector'],
                           url: activeAction['url'],
                           crawlId: crawlId,
                           a_id: action_id)
                .order(id: :desc)
                .first_or_create

    #
    # RENDERABLE
    #
    base_renderable = input['base_renderable']
    active_renderable = input['active_renderable']

    @base_renderable = Renderable.where(a_id: base_renderable['_id'],
                                        crawlId: crawlId,
                                        domain: base_renderable['domain'],
                                        action: @action,
                                        variation: @variation)
                         .order(id: :desc)
                         .first_or_create(renderedTitle: base_renderable['renderedTitle'],
                                          renderedURL: base_renderable['renderedURL'],
                                          control: true,
                                          screenshotFilename: base_renderable['screenshotFilename'])


    @active_renderable = Renderable.where(a_id: active_renderable['_id'],
                                          crawlId: crawlId,
                                          domain: active_renderable['domain'],
                                          action: @action,
                                          variation: @variation)
                           .order(id: :desc)
                           .first_or_create(renderedTitle: active_renderable['renderedTitle'],
                                            renderedURL: active_renderable['renderedURL'],
                                            control: false,
                                            screenshotFilename: active_renderable['screenshotFilename'],
                                            controlRenderable: @base_renderable)

    diffs = input['diffs']
    diffs = diffs.select{ |diff| !diff['is_ignore'] }

    @active_renderable.diffs.destroy_all

    diffs = diffs.each do |d|

      #TODO: add crawlId?: d['crawlId'], #doesn't exist, need to add in model
      _d = Diff.where(a_id: d['_id'],
                      crawlId: crawlId,
                      renderable: @active_renderable)
             .order(id: :desc)
             .first_or_create do |diff|

        #json isn't directly comparable in postgres (where clause)
        #TODO: trim this, throwing json is lazy
        diff.calculated = d['calculated']
        diff.newDim = d['newDim']
        diff.origDim = d['origDim']
        diff.summary_delta = d['summary_delta']
        diff.summary_added = d['summary_added']
        diff.summary_removed = d['summary_removed']
        diff.selector = d['selector']
        diff.diffType = d['type']


      end

    end

    #TODO: how to get Vendor name - variation - parser?
    #pause vendor model for now
    #@vendor = Vendor.new()

    render json: diffs
  end


end
