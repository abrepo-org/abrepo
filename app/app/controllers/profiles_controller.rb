class ProfilesController < ApplicationController

  def index
    p = profile_filter_params #{query: 'xyz', tag: '123'}

    @profiles = []
    if (p[:q])

      @profiles = Profile.search_company_name(p[:q])
                    .includes(:experiments)
                    .where.not(experiments: { profile_id: nil})
    else

      @profiles = Profile.includes(:experiments)
                    .where.not(experiments: { profile_id: nil})
    end


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
    params.permit(:q, :utf8, tags: [], industries: [])
  end
end
