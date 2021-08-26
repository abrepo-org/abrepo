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
    @results = Search.build(query, tags, industries)

    #
    # FROM PROFILE
    #
    @experiments = @results

    if (@experiments.length > 0)

      @profile = @experiments[0].profile
      @num_variations = @experiments.inject(0) { |sum, exp| sum + exp.variations.length }
      @action = {}
    end

    if (params[:partial])
      return render partial: "results"
    end
  end

end
