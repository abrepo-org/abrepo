class ProfilesController < ApplicationController
  include UserSavedVariationsHash

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

      profile_ids = @profiles.pluck(:id).uniq

      @profiles = @profiles
                    .tagged_with(@industries)


      # ISSUE: ordering of results
      # query sets a ranking
      # if there is no query we have no idea what the "order" should be
      # even if we have a way to order results, we don't know what that order should be
      # when there's no query
      # so back and forth things can move around
      #
      #.joins("JOIN unnest('{#{profile_ids.join(',')}}'::int[]) WITH ORDINALITY t(profile_id, ord) USING (profile_id)")
      #.reorder('t.ord')

    end

    if (@profiles.length > 0)
      @pagy, @profiles = pagy(@profiles, items: 20)
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
                     .includes(:source_vendor,
                               :audience,
                               variations: [:renderables, :tag, :page_tag])
                     .order(created_at: :desc)

    if (@experiments.length > 0)

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

      @user_saved_variations = user_saved_variations_hash
    end
  end

end
