class VariationsController < ApplicationController
  before_action :authenticate_user!, only: [:update]
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def show
    @variation = policy_scope(Variation)
                   .includes(:actions,
                             :renderables,
                             :tag, :page_tag,
                             experiment: [:profile, :campaign])
                   .find_by_id( params[:id] )

    raise ActionController::RoutingError.new('Not Found') if (@variation.nil?)

    # redirect; serve only to proper parameterized slug url (/:id/slug)
    vname = @variation.summary_name.parameterize
    redirect_to "/variations/#{@variation.id}/#{vname}" unless params[:name] == vname


    @experiment = @variation.experiment
    @campaign = @experiment.campaign
    @profile = @experiment.profile
    @actions = @variation.actions
    @usv = user_signed_in? && current_user
                                .user_saved_variations
                                .find_by_variation_id(@variation.id)


    #Sorted actions
    #sort by highest number of diffs, tie break to null Action
    #then return those actions
    if (@actions.count > 1)
      @actions = @variation.renderables.where(control: false)
                   .sort_by{ |r| [r.diffs.count, r.action.actionType == nil ? 1 : 0] }
                   .reverse.map(&:action)
    end


    # determine if obfuscate via visits stored in cookie
    @obfuscate = obfuscate_num_visits_variation_show(Rails
                                                       .application
                                                       .config
                                                       .max_visits_variation_show)

    if @obfuscate
      # text content
      [@experiment, @variation].each{ |e| e.obfuscate }

      # TODO:
      # set images on renderable to some subscribe now
    end

    #
    # main window.abrepo obj
    #
    defaultVisibleActions = { active: [], control: [] }
    @actionRenderables = {}

    @variation.renderables.where(control: false).each do |renderable|

      @actionRenderables[renderable.action_id] = {
        renderable: renderable.to_render,
        controlRenderable: renderable.controlRenderable.to_render,
        visibleActions: renderable.action.actionType.nil? ?
          @variation.visibleActions : defaultVisibleActions
      }

    end

    @renderable = @actionRenderables[ @actions[0].id ][:renderable]
    @variation_index = policy_scope(@experiment.variations).find_index(@variation)

    # moderators: generate abannotate submitPath: url source
    @submitPath = [
      ENV['ABANNOTATE_HOSTS'].split(",").first,
      'examples/profiles', @profile.a_id,
      'groups', @campaign.vendor_id,
      'variations', @variation.a_id
     ].join('/')

  end

  def update
    variation = authorize Variation.find(params[:id])
    if variation
      variation.update(variation_params)
    end
    redirect_to imports_path
  end


  private

  def variation_params
    params.require(:variation).permit(:id, :published)
  end

  def user_not_authorized(exception)
    redirect_to profiles_path
  end

end
