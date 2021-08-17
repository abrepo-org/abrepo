class Search

  #
  # BUILD QUERY
  # TODO: separate query build from search exeution
  
  def self.build(query, filters)
    variations = Variation     

    #freetext
    if (query)
      exp_ids = PgSearch.multisearch(q).pluck(:experiment_id).uniq
      variations = Variation.where(experiment_id: exp_ids)
    end

    #filters
    if (filters)
      variations = variations.tagged_with(filters)
    end

    variations.pluck(:id, :summary_name)
    #TODO: what am I returning - experiments and nested variations?
  end
end
