class ImportsController < ApplicationController
  protect_from_forgery with: :exception, except: :create
  before_action :authenticate_user!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  #
  #curl -i -H "Content-Type: application/json" -X POST localhost/imports/ -d '{"test":"123"}'
  #
  # a_id and/or content differences should trigger create -- but not
  # sure if entirely desirable

  def create
    authorize Experiment

    #
    # GROUP
    #
    input = params['input']
    group = input['group']

    profile = group['profile']

    # a_id: intended to lock the source of the submission - ideally,
    # was submited from prod
    #
    # we don't want to ovewrite a prod source record with dev data.
    #
    # note a_id isn't intended to be a unique domain identifier - we
    # assume domain uniqueness for now - when/if that gets violated
    # see abextract:/lib/models/README.md for migrations/handling
    # brainstorm
    #

    @profile = Profile.find_by(a_id: nil, domain: profile['domain'])

    # empty profile doesn't exist, so check if an existing a_id
    # profile exists - or go ahead and create it
    if @profile.nil?
      @profile = Profile
                   .where(a_id: profile['_id'],
                          domain: profile['domain'])
                   .order(id: :desc)
                   .first_or_create
    end

    logger.error(@profile.errors.full_messages) &&\
    logger.error("Profile: #{@profile.inspect}") && \
    logger.error("Profile Input: #{profile['domain']} - a_id: #{profile['_id']}") \
      unless @profile.valid?


    @profile.update(a_id: profile['_id'],
                    company_name: profile['company_name'],
                    industry_tag_list: group['tags']['industry_tag_list'],
                    url: profile['url'],
                    description: profile['description'],
                    description_source_name: profile['description_source_name'],
                    description_source_url: profile['description_source_url'],
                    favicon_url: profile['favicon_url'],
                    logo_url: profile['logo_url'])


    # if one day the same domain represents wholly different companies
    # look to abextract:/lib/models/README.md
    related_companies = group['profile']['related_companies']
    relateds = []
    related_companies.each do | related_company |

      related = Profile.find_or_create_by(domain: related_company['domain'])
      related.company_name = related_company['company_name'] if related.company_name.nil?

      if (!@profile.related_companies.include?(related))
        relateds.push(related)
      end
    end

    @profile.related_companies = relateds


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
                       audience_name: experiment['audienceName'],
                       source_vendor: @sourcevendor,
                       published: experiment['published'] || false,
                       profile: @profile)

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
                      verified: variation['annotationStatus'] == 'verified',
                      audience_name: variation['audienceName'],
                      experiment: @experiment)

    #
    # AUDIENCE
    # NB: submit experiment and variations with same audience_name in
    # event of multiple unique variation audiences, reset experiment
    # audience to blank (we can't really 'choose' among audiences at
    # experiment level) for vanilla experiments, audience is typically
    # singular and same across variations
    if (@experiment.variations.pluck(:audience_name).uniq.length > 1)
      @experiment.update(audience_name: nil)
    end

    #Action, Renderable, Diffs - pegged to Variation and crawlId
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

    @action.update(selectorDisplayName: activeAction['selectorDisplayName'],
                   description: activeAction['description'])

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
        diff.summary_added_format = d['summary_added_format'].blank? ?
                                      nil : d['summary_added_format']
        diff.summary_removed = d['summary_removed'].blank? ? nil : d['summary_removed']
        diff.summary_removed_format = d['summary_removed_format'].blank? ?
                                        nil : d['summary_removed_format']
        diff.selector = d['selector']
        diff.selectorDisplayName = d['selectorDisplayName']
        diff.diffType = d['type']
        diff.diffPanel = String( d['diffPanel'] )
        diff.viewMode = String( d['viewMode'] )
        diff.group_id = d['group_id']
      end

    end

    # update Experiment calcscore with avg Diff counts
    score = @experiment.score
    @experiment.update(calcscore: score)

    render json: {"success": true, "diffs": diffs}
  end


  def index

    @experiments = authorize Experiment
                               .includes(:variations)
                               .where(published: false)
                               .order(updated_at: :desc)

  end

  private

  def user_not_authorized(exception)
    respond_to do |format|
      format.json { render json: {"status": "Unauthorized"}, status: 401 }
      format.html { redirect_to profiles_path }
    end
  end

end
