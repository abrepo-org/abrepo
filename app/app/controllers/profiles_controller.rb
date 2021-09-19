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

      @num_variations = policy_scope(Variation)
                          .joins(:experiment)
                          .where({experiment: {profile_id: @profile.id}})
                          .select('experiment.id, COUNT(variations.id) as count')
                          .group('experiment.id')
                          .pluck('variations.count')
                          .sum

      @pagy, @experiments = pagy(@experiments)

      #Company tags and counts
      @tag_counts = ActsAsTaggableOn::Tag
                      .joins(:taggings)
                      .select('tags.id, tags.name, COUNT(taggings.id) as count')
                      .group('tags.id, tags.name')
                      .where(taggings: { taggable_type: 'Variation',
                                         taggable_id: policy_scope(Variation)
                                           .joins(:experiment)
                                           .where({experiment: {profile_id: @profile.id}})
                                       })
                      .order('tags.count desc')
                      .limit(10)
                      .map{ |tag| { id: tag[:id], name: tag[:name], count: tag['count'] } }

      @featured_experiments = policy_scope(Experiment).calcRank.limit(5)
    end


  end



  def profile_params
    params.permit(:id)
  end

end
