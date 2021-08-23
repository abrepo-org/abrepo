class SearchController < ApplicationController

  def show
    #TODO: highlight match snippet

    query = params[:query] || nil
    industries = [* params[:industries] || [] ]
    tags = [* params[:tags] || [] ]

    @tags = tags
    @industries = industries

    # Currently:
    # just passing params to view layer; no check for query validity
    # show params in query even if not valid tags
    # keep Search model as filter/results search generator
    @results = Search.build(query, tags, industries)

    if (params[:partial])
      return render partial: "results"
    end
  end

end
