class ProfilesController < ApplicationController

  def index
    @query = params[:query].blank? ? nil : params[:query]
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

    #sidebar
    @top_profiles = Sidebar.top_profiles

    @top_industries = Sidebar.top_industries

    # featured experiments
    # choose experiments:
    # 1. featured: true -> defer for now
    # 2. or topN of calcRank
    @featured_experiments = Experiment.calcRank.limit(5)


    if params[:partial]
      respond_to do |format|
        format.html { render partial: 'profile_cards' }
      end
    end
  end


  def show
    @profile = Profile.includes(experiments: {variations: :renderables})
                 .find_by_id(params[:id])

    @experiments = policy_scope(@profile.experiments)

    if (@experiments.length > 0)

      @profile = @experiments[0].profile

      @num_variations = policy_scope(Variation)
                          .joins(:experiment)
                          .where({experiment: {profile_id: @profile.id}})
                          .select('experiment.id, COUNT(variations.id) as count')
                          .group('experiment.id')
                          .pluck('variations.count')
                          .sum

      @pagy, @experiments = pagy(@experiments)

      @tag_counts = Sidebar.top_tags(@profile)

      @featured_experiments = policy_scope(Experiment).calcRank.limit(5)
    end
  end

end
