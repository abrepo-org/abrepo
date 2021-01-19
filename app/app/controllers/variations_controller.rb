class VariationsController < ApplicationController

  def show
    @variation = Variation.includes(:actions,
                                    :renderables,
                                    experiment: [:profile, :audience, :campaign])
                   .find_by_id( variation_params[:id] )

    @experiment = @variation.experiment
    @audience = @experiment.audience
    @campaign = @experiment.campaign
    @profile = @experiment.profile
    @actions = @variation.actions

    #TODO: action sort; assumption require null action to be first?
    renderables = Renderable
                    .where(variation_id: @variation, control:false)
                    .order(id: :desc)
    @renderable = renderables[0]

    @actionRenderables = {}
    renderables.each do |renderable|
      @actionRenderables[renderable.action_id] = {
        renderable: renderable.to_render,
        controlRenderable: renderable.controlRenderable.to_render
      }
    end

    @variation_index = @experiment.variations.find_index(@variation)


  end

  def variation_params
    params.permit(:id)
  end
end
