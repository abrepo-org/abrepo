class VariationsController < ApplicationController

  def show
    @variation = policy_scope(Variation)
                   .includes(:actions,
                             :renderables,
                             experiment: [:profile, :audience, :campaign])
                   .find_by_id( variation_params[:id] )

    raise ActionController::RoutingError.new('Not Found') if (@variation.nil?)


    @experiment = @variation.experiment
    @audience = @experiment.audience
    @campaign = @experiment.campaign
    @profile = @experiment.profile
    @actions = @variation.actions

    #Sorted actions
    #sort by highest number of diffs, tie break to null Action
    #then return those actions
    if (@actions.count > 1)
      @actions = @variation.renderables.where(control: false)
                   .sort_by{ |r| [r.diffs.count, r.action.actionType == nil ? 1 : 0] }
                   .reverse.map(&:action)
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

  end

  def variation_params
    params.permit(:id)
  end
end
