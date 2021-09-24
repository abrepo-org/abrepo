class Search
  include Pundit
  #
  # BUILD QUERY
  # TODO: separate query build from search exeution

  def self.build(query, filters, industries,
                 experimentPolicyModel, variationPolicyModel)

    exp_ids = []
    variations = nil
    profiles = nil

    #freetext
    if (query)
      exp_ids = PgSearch.multisearch(query)
                  .pluck(:experiment_id)
                  .uniq

      profile_exp_ids = Experiment
                          #.where(profile_id: Profile.search_industry(query).pluck(:id))
                          .where(profile_id: Profile.search_industry_and_company(query).pluck(:id))
                          .pluck(:id)
      #
      # updated freetext exp_ids
      # join with any Profile.search_company experiment matches
      #
      exp_ids = (exp_ids + profile_exp_ids).uniq

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

      profile_ids = Profile.tagged_with(industries)
                      .pluck(:id).uniq

      profile_exp_ids = experimentPolicyModel
                          .where(profile_id: profile_ids)
                          .pluck(:id)

      variations = (variations || variationPolicyModel)
                     .includes(experiment: [:audience])
                     .includes(:renderables)
                     .where(experiment_id: profile_exp_ids)

    end

    #
    # NB: chaining queries above loses multisearch rank ordering of
    # the exp_ids. So at the end of all the query / filtering, we use
    # the original exp_ids to "re-order" via unnest-ORDINALITY in
    # postgres
    #

    if (variations)

      experiments = Experiment.where(id: variations.pluck(:experiment_id).uniq )

      # attach join
      # reorder using exp_ids freetext ordering
      # reorder('t.ord') crucial or else get mal-ordred pagy results
      if (exp_ids.length > 0)
        experiments = experiments
                        .joins("JOIN unnest('{#{exp_ids.join(',')}}'::int[]) WITH ORDINALITY t(id, ord) USING (id)")
                        .reorder('t.ord')

      end

      return experiments
    end


    return []

  end
end
