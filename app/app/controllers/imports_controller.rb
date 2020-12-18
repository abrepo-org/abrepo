class ImportsController < ApplicationController
  protect_from_forgery except: :create


  def test
    render json: params
  end

  #
  #curl -i -H "Content-Type: application/json" -X POST localhost/imports/ -d '{"test":"123"}'
  #
  def create
    #
    # GROUP
    #
    input = params['input']
    group = input['group']

    profile = group['profile']
    @profile = Profile.new(a_id: profile['_id'],
                           domain: profile['domain'])

    experiment = group['experiment']
    expSummary = input['experimentSummary']
    exp_name = experiment['name']

    #description as method
    @experiment = Experiment.new(a_id: experiment['_id'],
                                 name: exp_name,
                                 crawlID: experiment['crawlId'],
                                 domain: experiment['domain'],
                                 gen_desc: experiment['gen_desc'],
                                 experimentSummary: expSummary['manual_summarization'],
                                 profile: @profile)

    campaign = group['campaign']
    @campaign = Campaign.new(a_id: campaign['_id'],
                             name: campaign['name'],
                             experiment: @experiment)


    variation = group['variation']
    varSummary = input['variationSummary']
    var_name = varSummary['manual_summarization'] ||
               variation['gen_desc'] ||
               variation['name']
    @variation = Variation.new(a_id: variation['_id'],
                               name: var_name,
                               gen_desc: variation['gen_desc'],
                               url: variation['crawlURL'],
                               variationSummary: varSummary['manual_summarization'],
                               experiment: @experiment)

    action_id = input['action_id'] #not sure of use at this point
    @action = Action.new(a_id: action_id)
    #TODO: Action: get content - more than id?

    #TODO: change to findOrCreate
    diffs = input['diffs']
    diffs = diffs.select{ |diff| !diff['is_ignore'] }
    diffs = diffs.map{ |d|
      {
        _id: d['_id'],
        action_id: d['action_id'],
        calculated: d['calculated'],
        crawlId: d['crawlId'],
        diffSummary: d['diffSummary'], #text (not object)
        is_ignore: d['is_ignore'],
        newDim: d['newDim'], #json
        origDim: d['origDim'], #json
        selector: d['selector'],
        summarization: d['summarization'],
        type: d['type']
      }
    }


    #TODO add diffSummary to text
    base_renderable = input['base_renderable']
    active_renderable = input['active_renderable']
    @base_renderable = Renderable.new(a_id: base_renderable['_id'],
                                      domain: base_renderable['domain'],
                                      renderedTitle: base_renderable['renderedTitle'],
                                      renderedURL: base_renderable['renderedURL'],
                                      control: true,
                                      screenshotFilename: base_renderable['screenshotFilename'],
                                      action: @action)

    @active_renderable = Renderable.new(a_id: active_renderable['_id'],
                                        domain: active_renderable['domain'],
                                        renderedTitle: active_renderable['renderedTitle'],
                                        renderedURL: active_renderable['renderedURL'],
                                        control: false,
                                        screenshotFilename: active_renderable['screenshotFilename'],
                                        diff: diffs,
                                        action: @action,
                                        variation: @variation,
                                        controlRenderable: @base_renderable)





    #TODO: how to get Vendor name - variation - parser?
    #pause vendor model for now
    #@vendor = Vendor.new()


    #TODO: deprecated
    # audience, diff models


    # not necessary - use what's in renderable?
    # @base_boundingBoxes = base_boundingBoxes
    #                         .select{ |bbox| @diffs.any? { |diff| diff['_id'] == bbox['_id']  } }
    # @active_boundingBoxes = active_boundingBoxes
    #                           .select{ |bbox| @diffs.any? { |diff| diff['_id'] == bbox['_id']  } }


    #Diff migrations -> for now save as json array attribute in Renderable
    # possible model migrations:
    # rename "change" -> "type"
    # a_id (annotation_id - mongo)
    # diff - belongs_to "active_renderable_id" fkey, renderable has_many diffs
    #   since Renderable has_one to itself control Reference, diffs can just have one renderable



    render json: diffs
  end
end
