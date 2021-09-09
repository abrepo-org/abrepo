class ExperimentsController < ApplicationController

  def update
    experiment = Experiment.find(params[:id])
    if experiment
      experiment.update(experiment_params)
    end
    redirect_to imports_path
  end


  private

  def experiment_params
    params.require(:experiment).permit(:id, :published)
  end
end
