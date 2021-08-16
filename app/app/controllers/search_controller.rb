class SearchController < ApplicationController

  def show
    #TODO: highlight match snippet

    #
    # BUILD QUERY
    #

    #freetext
    variations = Variation

    if(params[:q])
      q = params[:q]
      exp_ids = PgSearch.multisearch(q).pluck(:experiment_id).uniq
      variations = Variation.where(experiment_id: exp_ids)
    end

    #filters
    if (params[:tags])
      tags = params[:tags]
      variations = variations.tagged_with(tags)
    end

    blob = variations.pluck(:id, :summary_name)

    #TODO: what am I returning - experiments and nested variations?

    render json: blob
  end

end
