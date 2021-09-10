class ProfilesController < ApplicationController

  def index
    @query = params[:query] || nil
    @industries = [* params[:industries] ]

    @profiles = Profile
                  .includes(:experiments)
                  .where.not(experiments: { profile_id: nil})

    if @query
      @profiles = @profiles.search_company(@query)
    end

    unless @industries.empty?
      @profiles = @profiles.tagged_with(@industries)
    end

  end


  def show
    @profile = Profile.includes(experiments: {variations: :renderables})
                 .find_by_id(profile_params[:id])

    @experiments = policy_scope(@profile.experiments)

    if (@experiments.length > 0)

      @profile = @experiments[0].profile
      @num_variations = @experiments
                          .inject(0) { |sum, exp| sum + policy_scope(exp.variations).length }
      @pagy, @experiments = pagy(@experiments)

    end

  end



  def profile_params
    params.permit(:id)
  end

end
