class SearchController < ApplicationController

  def show
    #TODO: highlight match snippet

    query = params[:query]
    filters = params[:tags]
    industries = params[:industries]

    @results = Search.build(query, filters, industries)

    if (params[:partial])
      return render partial: "results"
    end
  end

end
