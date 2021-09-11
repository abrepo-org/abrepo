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
      @num_variations = @experiments.inject(0) { |sum, exp| sum + policy_scope(exp.variations).length }
    end

    if (params[:partial])
      return render partial: "results"
    end
  end

end
