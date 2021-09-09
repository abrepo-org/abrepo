class ExperimentsController < ApplicationController
  before_action :authenticate_user!, only: [:update]
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def update
    experiment = authorize Experiment.find(params[:id])
    if experiment
      experiment.update(experiment_params)
    end
    redirect_to imports_path
  end


  private

  def experiment_params
    params.require(:experiment).permit(:id, :published)
  end

  def user_not_authorized(exception)
    redirect_to profiles_path
  end

end
