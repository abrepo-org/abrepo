class Search
  include Pundit
  #
  # BUILD QUERY
  # TODO: separate query build from search exeution

  def self.build(query, filters, industries,
                 experimentPolicyModel, variationPolicyModel)

    variations = nil

    #freetext
    if (query)
      exp_ids = PgSearch.multisearch(query).pluck(:experiment_id).uniq
      variations = (variations || variationPolicyModel)
                     .includes(experiment: [:audience])
                     .includes(:renderables)
                     .where(experiment_id: exp_ids)
    end

    #filters: tag/page_tag
    unless (filters.empty?)
      variations = (variations || variationPolicyModel)
                     .includes(experiment: [:audience])
                     .includes(:renderables)
                     .tagged_with(filters)
    end

    #industries
    unless (industries.empty?)

      profile_ids = Profile.tagged_with(industries).pluck(:id).uniq
      experiments = experimentPolicyModel.where(profile_id: profile_ids).pluck(:id)
      variations = (variations || variationPolicyModel)
                     .includes(experiment: [:audience])
                     .includes(:renderables)
                     .where(experiment_id: experiments)
    end

    if (variations)
      return Experiment.where(id: variations.pluck(:experiment_id))
    end

    return []
  end
end
