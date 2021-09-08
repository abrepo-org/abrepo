class ImportsController < ApplicationController
  protect_from_forgery with: :exception, except: :create
  before_action :authenticate_user!

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
    @profile = Profile
                 .where(a_id: profile['_id'],
                        domain: profile['domain'])
                 .order(id: :desc)
                 .first_or_create

    @profile.update(company_name: profile['company_name'],
                    industry_tag_list: group['tags']['industry_tag_list'],
                    url: profile['url'],
                    description: profile['description'],
                    favicon_url: profile['favicon_url'],
                    logo_url: profile['logo_url'])

    #related companies
    related_companies = group['profile']['related_companies']
    related_companies.each do | related_company |

      related = Profile.find_or_initialize_by(domain: related_company['domain'],
                                              a_id: related_company['_id'])
      related.company_name = related_company['company_name']

      unless related.id
        @profile.related_companies.push(related)
      end

    end

    puts @profile.related_companies.inspect

    #
    # VENDOR
    #

    @sourcevendor = SourceVendor
                      .where(name: group['experiment']['vendor_type'])
                      .first_or_create

    #
    # EXPERIMENT
    #

    experiment = group['experiment']
    @experiment = Experiment
                    .where(vendor_id: experiment['experiment_id'],
                           a_id: experiment['_id'])
                    .order(id: :desc)
                    .first_or_create

    @experiment.update(crawlId: experiment['crawlId'],
                       domain: experiment['domain'],
                       summary_name: experiment['summary_name'],
                       source_vendor: @sourcevendor,
                       published: experiment['published'] || false,
                       profile: @profile)


    @audience = Audience
                  .where(name: experiment['audienceName'],
                         experiment: @experiment)
                  .order(id: :desc)

    @audience.first_or_create

    campaign = group['campaign']
    @campaign = Campaign
                  .where(vendor_id: campaign['campaign_id'],
                         a_id: campaign['_id'])
                  .order(id: :desc)
                  .first_or_create

    @campaign.update(name: campaign['name'],
                     experiment: @experiment)


    #
    # VARIATION
    # TODO: add crawlId: variation['crawlId'],
    variation = group['variation']

    @variation = Variation
                   .where(a_id: variation['_id'],
                          vendor_id: variation['variation_id'])
                   .order(id: :desc)
                   .first_or_create

    @variation.update(summary_name: variation['summary_name'],
                      url: variation['crawlURL'],
                      tag_list: variation['tags']['tag_list'],
                      page_tag_list: variation['tags']['page_tag_list'],
                      published: variation['published'] || false,
                      experiment: @experiment)

    #Aciton, Renderable, Diffs - pegged to Variation and crawlId
    crawlId = variation['crawlId']

    #
    #'active' ACTION
    #
    action_id = input['action_id']
    activeAction = input['activeAction']

    @action = Action.where(actionType: activeAction['type'],
                           selector: activeAction['selector'],
                           url: activeAction['url'],
                           crawlId: crawlId,
                           a_id: action_id)
                .order(id: :desc)
                .first_or_create

    @action.update(selectorDisplayName: activeAction['selectorDisplayName'])

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
                         .first_or_create

    @base_renderable.update(renderedTitle: base_renderable['renderedTitle'],
                            renderedURL: base_renderable['renderedURL'],
                            preExecuteAction: base_renderable['preExecuteAction'],
                            control: true,
                            screenshotWidth: base_renderable['screenshotDimensions']['width'],
                            screenshotHeight: base_renderable['screenshotDimensions']['height'],
                            screenshotFilename: base_renderable['screenshotFilename'])


    @active_renderable = Renderable.where(a_id: active_renderable['_id'],
                                          crawlId: crawlId,
                                          domain: active_renderable['domain'],
                                          action: @action,
                                          variation: @variation)
                           .order(id: :desc)
                           .first_or_create

    @active_renderable.update(renderedTitle: active_renderable['renderedTitle'],
                              renderedURL: active_renderable['renderedURL'],
                              preExecuteAction: active_renderable['preExecuteAction'],
                              control: false,
                              screenshotWidth: active_renderable['screenshotDimensions']['width'],
                              screenshotHeight: active_renderable['screenshotDimensions']['height'],
                              screenshotFilename: active_renderable['screenshotFilename'],
                              controlRenderable: @base_renderable)

    diffs = input['diffs']
    diffs = diffs.select{ |diff| !diff['is_ignore'] }

    @active_renderable.diffs.destroy_all

    diffs = diffs.each do |d|

      #TODO: add crawlId?: d['crawlId'], #doesn't exist, need to add in model
      Diff.where(a_id: d['_id'],
                 crawlId: crawlId,
                 renderable: @active_renderable)
        .order(id: :desc)
        .first_or_create do |diff|

        #json isn't directly comparable in postgres (where clause)
        #TODO: trim this, throwing json is lazy

        diff.calculated = d['calculated']
        diff.newDim = d['newDim']
        diff.origDim = d['origDim']
        diff.summary_delta = d['summary_delta'].blank? ? nil : d['summary_delta']
        diff.summary_added = d['summary_added'].blank? ? nil : d['summary_added']
        diff.summary_removed = d['summary_removed'].blank? ? nil : d['summary_removed']
        diff.selector = d['selector']
        diff.selectorDisplayName = d['selectorDisplayName']
        diff.diffType = d['type']
        diff.diffPanel = String( d['diffPanel'] )
        diff.viewMode = String( d['viewMode'] )
        diff.group_id = d['group_id']
      end

    end

    render json: {"success": true, "diffs": diffs}
  end


end
