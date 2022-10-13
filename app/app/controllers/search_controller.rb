class SearchController < ApplicationController
  include UserSavedVariationsHash

  def index

    @query, @tags, @industries = Search.extractSearchParams(params[:query])

    @search_input_text = Search.buildSearchQuery(@query, @tags, @industries)

    @experiments, @expvarHighlightHash = Search
                                           .build(@query, @tags, @industries,
                                                  policy_scope(Experiment)
                                                    .includes(:profile,
                                                              :source_vendor,
                                                              :variations),
                                                  policy_scope(Variation))


    @profiles, @profileHighlightHash = Profile.search_company(@query,
                                                              policy_scope(Profile)
                                                                .includes(:industry_tag))

    if (@experiments.empty?)
      @experiments = policy_scope(Experiment).where(profile: @profiles)
    end

    # TODO: filter profiles by (tags, industries)
    if (@experiments.length > 0)
      @pagy, @experiments = pagy(@experiments)
    end

    # Possible increase search results to 1st page?
    @experiments = obfuscate_from(@experiments,
                                  num_given_pagination(@experiments.length)) if not subscribed_or_moderator

    @variations = policy_scope(Variation)
                    .includes({experiment: :profile},
                              :renderables,
                              :tag, :page_tag)
                    .where(experiment_id: @experiments)
                    .order([
                             "variations.verified desc",
                             "variations.created_at desc",
                             "variations.summary_name asc"
                           ])

    # autocomplete
    if (params[:partial])
      return render partial: "results"
    end

    #sidebar
    @top_profiles = Sidebar.top_profiles

    @top_industries = Sidebar.top_industries

    # featured experiments
    # choose experiments:
    # 1. featured: true -> defer for now
    # 2. or topN of calcRank
    @featured_experiments = policy_scope(Experiment)
                              .includes(:profile)
                              .calcRank(5)

    @user_saved_variations = user_saved_variations_hash
  end

end
