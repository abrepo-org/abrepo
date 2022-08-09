class Search
  include Pundit

  # combines params to create query string (form use, urls)
  def self.buildSearchQuery(query, tags, industries)
    return [
      query.join(" "),
      tags.map{ |tag| "[#{tag}]" }.join(" "),
      industries.map{ |industry| "{#{industry}}" }.join(" "),
    ].filter{ |q| !q.empty? }.join(" ").strip
  end

  #
  # BUILD QUERY
  #
  # 1. query with PgSearch across Experiments and Variations
  #    * store results in DocHash to get pg_search_highlight
  #
  # 2. filter result set with tags or industry if provided
  #
  # Variations are the intermediate query and filter "result", which is used 
  # to get the final Experiment (ExpVar) results
  #
  # the results are ordered by_search rank (in case of a query),
  # or default to most recent date order
  #
  def self.build(query, tags, industries,
                 experimentPolicyModel, variationPolicyModel)

    exp_ids = []
    experiments = []
    experimentsDocHash = {}
    variationsDocHash = {}
    variations = nil
    profiles = nil

    #freetext
    unless (query.empty?)

      search = PgSearch.multisearch(query)
                 .with_pg_search_rank
                 .with_pg_search_highlight

      #issue with Experiments and Variations
      #only some experiments and variations will have highlighted match
      #but we're collecting all experiment
      #so I guess we have to test in the view for pg_search_highlight content
      experimentsDocHash = search
                             .where(searchable_type: "Experiment")
                             .index_by(&:searchable_id)

      variationsDocHash = search
                            .where(searchable_type: "Variation")
                            .index_by(&:searchable_id)

      # calc avg rank across Experiment and Variations this re-score
      # can change; think its somewhat fair a sum would favor large
      # experiments with more variations, not necessarily relevance.

      scores = {}
      search
        .pluck(:experiment_id, :rank)
        .each do |id, rank|
          scores[id] ||= 0
          scores[id] += rank
          scores[id] = scores[id] / 2
        end

      #[ [experiment_id, rank], [experiment_id, rank]...]
      exp_order = scores.sort_by{ |id, rank| -rank }
      exp_ids = exp_order.map{ |r| r[0] }

      variations = variationPolicyModel
                     .where(experiment_id: exp_ids)

    end

    #filters: tag/page_tag
    unless (tags.empty?)

      variations = (variations || variationPolicyModel)
                     .includes(:experiment)
                     .includes(:renderables)
                     .tagged_with(tags)

    end

    #filters: industries
    unless (industries.empty?)

      profile_ids = Profile.tagged_with(industries)
                      .pluck(:id).uniq

      profile_exp_ids = experimentPolicyModel
                          .where(profile_id: profile_ids)
                          .pluck(:id)

      variations = (variations || variationPolicyModel)
                     .includes(:experiment)
                     .includes(:renderables)
                     .where(experiment_id: profile_exp_ids)

    end

    #
    # NB: chaining queries above loses multisearch rank ordering of
    # the exp_ids. So at the end of all the query / filtering, we use
    # the original exp_ids to "re-order" via unnest-ORDINALITY in
    # postgres
    #

    # no query, no filters - return all, date orderered
    if (variations.blank? && (industries.empty? && tags.empty? && query.empty?))
      return [experimentPolicyModel.order(created_at: "DESC"), {}, {}]
    else

      experiments = experimentPolicyModel
                      .where(id: variations.pluck(:experiment_id).uniq )


      # attach join
      # reorder using exp_ids freetext ordering
      # otherwise by date
      # reorder('t.ord') crucial or else get mal-ordred pagy results
      if (exp_ids.empty?)
        experiments = experimentPolicyModel
                        .where(id: variations.pluck(:experiment_id).uniq )
                        .order(created_at: "DESC")
      else
        experiments = experiments
                        .joins("JOIN unnest('{#{exp_ids.join(',')}}'::int[]) WITH ORDINALITY t(id, ord) USING (id)")
                        .reorder('t.ord')

      end
    end


    return [experiments, experimentsDocHash, variationsDocHash]

  end
end
