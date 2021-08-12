class SearchController < ApplicationController

  def show
    render json: params
  end

end
