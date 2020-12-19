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
    @profile = Profile.where(a_id: profile['_id'],
                             domain: profile['domain'],
                             company_name: profile['company_name']).first_or_create

    experiment = group['experiment']
    expSummary = input['experimentSummary']
    exp_name = experiment['name']

    #
    # EXPERIMENT
    #
    @experiment = Experiment.where(crawlID: experiment['crawlId'],
                                   domain: experiment['domain'],
                                   a_id: experiment['_id'],
                                   name: exp_name,
                                   gen_desc: experiment['gen_desc'],
                                   experimentSummary: expSummary['manual_summarization'],
                                   profile: @profile).first_or_create

    @audience = Audience.where(name: experiment['audienceName'],
                               experiment: @experiment).first_or_create

    campaign = group['campaign']
    @campaign = Campaign.where(a_id: campaign['_id'],
                               name: campaign['name'],
                               experiment: @experiment).first_or_create


    #
    # VARIATION
    # TODO: add crawlID: variation['crawlId'],
    variation = group['variation']
    varSummary = input['variationSummary']
    @variation = Variation.where(a_id: variation['_id'],
                                 name: variation['name'],
                                 gen_desc: variation['gen_desc'],
                                 variationSummary: varSummary['manual_summarization'],
                                 url: variation['crawlURL'],
                                 experiment: @experiment).first_or_create
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
                           crawlID: variation['crawlId'],
                           a_id: action_id).first_or_create

    #
    # RENDERABLE
    #
    base_renderable = input['base_renderable']
    active_renderable = input['active_renderable']

    @base_renderable = Renderable.where(a_id: base_renderable['_id'],
                                        domain: base_renderable['domain'],
                                        renderedTitle: base_renderable['renderedTitle'],
                                        renderedURL: base_renderable['renderedURL'],
                                        control: true,
                                        screenshotFilename: base_renderable['screenshotFilename'],
                                        action: @action,
                                        variation: @variation).first_or_create


    @active_renderable = Renderable.where(a_id: active_renderable['_id'],
                                          domain: active_renderable['domain'],
                                          renderedTitle: active_renderable['renderedTitle'],
                                          renderedURL: active_renderable['renderedURL'],
                                          control: false,
                                          screenshotFilename: active_renderable['screenshotFilename'],
                                          action: @action,
                                          variation: @variation,
                                          controlRenderable: @base_renderable).first_or_create

    diffs = input['diffs']
    diffs = diffs.select{ |diff| !diff['is_ignore'] }

    diffs = diffs.each do |d|

      #TODO: add crawlId?: d['crawlId'], #doesn't exist, need to add in model
      _d = Diff.where(a_id: d['_id'],
                      is_ignore: d['is_ignore'],
                      selector: d['selector'],
                      diffType: d['type'],
                      renderable: @active_renderable)
             .first_or_create do |diff|

        #json isn't directly comparable in postgres (where clause)
        #TODO: trim this, throwing json is lazy
        diff.calculated = d['calculated']
        diff.diffSummary = d['diffSummary']
        diff.newDim = d['newDim']
        diff.origDim = d['origDim']
        diff.summarization = d['summarization']

      end

    end

    #TODO: how to get Vendor name - variation - parser?
    #pause vendor model for now
    #@vendor = Vendor.new()

    render json: diffs
  end


end
