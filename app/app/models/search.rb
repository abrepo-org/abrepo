class Search

  #
  # BUILD QUERY
  # TODO: separate query build from search exeution

  def self.build(query, filters, industries)

    variations = nil

    #freetext
    if (query)
      exp_ids = PgSearch.multisearch(query).pluck(:experiment_id).uniq
      variations = (variations || Variation)
                     .includes(experiment: [:audience])
                     .includes(:renderables)
                     .as_published
                     .where(experiment_id: exp_ids)
    end

    #filters: tag/page_tag
    unless (filters.empty?)
      variations = (variations || Variation)
                     .includes(experiment: [:audience])
                     .includes(:renderables)
                     .as_published
                     .tagged_with(filters)
    end

    #industries
    unless (industries.empty?)
      profile_ids = Profile.tagged_with(industries).pluck(:id).uniq
      experiments = Experiment.as_published.where(profile_id: profile_ids).pluck(:id)
      variations = (variations || Variation)
                     .includes(experiment: [:audience])
                     .includes(:renderables)
                     .as_published
                     .where(experiment_id: experiments)
    end

    #TODO: add an experiment or variation scope to filter experiments?
    (variations || []).map{ |variation| variation.experiment }

  end
end
