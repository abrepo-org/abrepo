class ProfilesController < ApplicationController

  def index
    @profiles = Profile.all().limit(20)
  end

  def show    
    @profile = Profile.find_by_id(profile_params[:id])
    @experiments = @profile.experiments

    @num_variations = Variation
                        .where(experiment_id: @experiments.pluck(:id))
                        .count()
    
  end



  def profile_params
    params.permit(:id)
  end
end
