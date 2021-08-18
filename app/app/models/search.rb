class Search

  #
  # BUILD QUERY
  # TODO: separate query build from search exeution

  def self.build(query, filters, industries)
    variations = Variation

    #freetext
    if (query)
      exp_ids = PgSearch.multisearch(query).pluck(:experiment_id).uniq
      variations = Variation.where(experiment_id: exp_ids)
    end

    #filters: tag/page_tag
    if (filters)
      variations = variations.tagged_with(filters)
    end

    #industries
    if (industries)
      profile_ids = Profile.tagged_with(industries).pluck(:id).uniq
      experiments = Experiment.where(profile_id: profile_ids).pluck(:id)
      variations = variations.where(experiment_id: experiments)
    end

    variations.pluck(:id, :summary_name)
    #TODO: what am I returning - experiments and nested variations?
  end
end
