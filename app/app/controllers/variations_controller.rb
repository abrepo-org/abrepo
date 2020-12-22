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
    #action sort?
    renderables = Renderable
                    .where(variation_id: @variation, control:false)
                    .order(id: :desc)

    @renderable = renderables[0]
    @controlRenderable = @renderable.controlRenderable

    #puts @renderables.length

  end

  def variation_params
    params.permit(:id)
  end
end
