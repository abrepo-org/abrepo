class SearchController < ApplicationController

  def show
    #TODO: highlight match snippet

    query = params[:query]
    filters = params[:tags]
    industries = params[:industries]
    @results = Search.build(query, filters, industries)
  end

end
