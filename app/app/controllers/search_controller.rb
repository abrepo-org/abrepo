class SearchController < ApplicationController
  include UserSavedVariationsHash

  def index
    #TODO: highlight match snippet

    query = []
    qry_tags = []
    qry_industries = []

    if params[:query]
      #split off tags, industries
      params[:query].split.each do |qry|
        if qry[0] == "[" && qry[-1] == "]"
          qry_tags.push(qry[1..-2])
        elsif  qry[0] == "{" && qry[-1] == "}"
          qry_industries.push(qry[1..-2])
        else
          query.push(qry)
        end
      end

    end

    tags = [* params[:tags] || qry_tags || [] ]
    industries = [* params[:industries] ||qry_industries || [] ]

    @query = query
    @tags = tags
    @industries = industries

    @search_input_text = Search.buildSearchQuery(query, tags, industries)

    # Currently:
    # just passing params to view layer; no check for query validity
    # show params in query even if not valid tags
    # keep Search model as filter/results search generator
    @experiments,
    @experimentsDocHash,
    @variationsDocHash = Search.build(query, tags, industries,
                                      policy_scope(Experiment),
                                      policy_scope(Variation))


    if (@experiments.length > 0)
      @pagy, @experiments = pagy(@experiments)

      # these are num search results, but we keep variable
      # as @num_variations to reuse partial
      @num_variations = policy_scope(Variation)
                          .where(experiment_id: @experiments)
                          .select('experiment_id, COUNT(variations.id) as count')
                          .group('experiment_id')
                          .pluck('variations.count')
                          .sum

    end

    # Possible increase search results to 1st page?
    @experiments = obfuscate_from(@experiments,
                                  num_given_pagination(@experiments.length)) if not subscribed_or_moderator

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
    @featured_experiments = policy_scope(Experiment).calcRank(5)

    @user_saved_variations = user_saved_variations_hash
  end

end
