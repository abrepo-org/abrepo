class SearchController < ApplicationController

  def show
    #TODO: highlight match snippet

    query = params[:q]
    filters = params[:tags]
    @results = Search.build(query, filters)
  end

end
