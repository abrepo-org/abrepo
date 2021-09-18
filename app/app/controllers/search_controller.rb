class SearchController < ApplicationController

  def index
    #TODO: highlight match snippet

    query = params[:query] || nil
    industries = [* params[:industries] || [] ]
    tags = [* params[:tags] || [] ]

    @query = query
    @tags = tags
    @industries = industries

    # Currently:
    # just passing params to view layer; no check for query validity
    # show params in query even if not valid tags
    # keep Search model as filter/results search generator
    @experiments = Search.build(query, tags, industries,
                                policy_scope(Experiment), policy_scope(Variation))

    if (@experiments.length > 0)
      @pagy, @experiments = pagy(@experiments)

      # these are num search results, but we keep variable
      # as @num_variations to reuse partial
      @num_variations = policy_scope(Variation)
                          .joins(:experiment)
                          .where(experiment: @experiments)
                          .select('experiments.id, COUNT(variations.id) as count')
                          .group('experiments.id')
                          .pluck('variations.count')
                          .sum

    end

    if (params[:partial])
      return render partial: "results"
    end
  end

end
