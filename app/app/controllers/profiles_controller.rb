class ProfilesController < ApplicationController

  def index
    p = profile_filter_params #{query: 'xyz', tag: '123'}
    @profiles = Profile.all().limit(20)
  end

  def show
    @profile = Profile.includes(experiments: {variations: :renderables})
                 .find_by_id(profile_params[:id])
    @experiments = @profile.experiments
    @num_variations = @experiments.inject(0) { |sum, x| sum + x.variations.length }

    #need action
    @renderable = @experiments[0].variations[0].renderables[0]

    #TODO: populate audience, vendor
    @audience = {'name': 'audienceName'}
    @vendor = { 'ABType': 1, 'name': "Optimizely" }
    @action = {}

    # @num_variations = Variation
    #                     .where(experiment_id: @experiments.pluck(:id))
    #                     .count()

  end



  def profile_params
    params.permit(:id)
  end

  def profile_filter_params
    #NB array params must go at end
    params.permit(:query, :utf8, tags: [], industries: [])
  end
end
