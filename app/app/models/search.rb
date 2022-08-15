class Search
  include Pundit

  def self.extractSearchParams(queryParam)

    query = []
    tags = []
    industries = []

    if queryParam
      queryParam.split.each do |qry|
        if qry[0] == "[" && qry[-1] == "]"
          tags.push(qry[1..-2])
        elsif  qry[0] == "{" && qry[-1] == "}"
          industries.push(qry[1..-2])
        else
          query.push(qry)
        end
      end
    end

    return query, tags, industries
  end

  # combines params to create query string (form use, urls)
  def self.buildSearchQuery(query, tags, industries)
    return [
      query.join(" "),
      tags.map{ |tag| "[#{tag}]" }.join(" "),
      industries.map{ |industry| "{#{industry}}" }.join(" "),
    ].filter{ |q| !q.empty? }.join(" ").strip
  end

  #
  # query freetext Search with pgSearch + avg rank
  #
  def self.querySearch(query, variationPolicyModel)

    search = PgSearch.multisearch(query)
               .with_pg_search_rank
               .with_pg_search_highlight

    # NB: only some experiments and/or variations have query highlights
    # even though we return all parent Experiments to render "ExpVar"
    experimentsDocHash = search
                           .where(searchable_type: "Experiment")
                           .index_by(&:searchable_id)

    variationsDocHash = search
                          .where(searchable_type: "Variation")
                          .index_by(&:searchable_id)

    # Currently: calc avg rank across Experiment and Variations this
    # re-score can change; think its somewhat fair a sum would favor
    # large experiments with more variations, not necessarily
    # relevance.
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

    # collect to preserve rank order of search query
    # that gets lost in subsequent queries
    exp_ids = exp_order.map{ |r| r[0] }

    # we collect relevant variations, and filter with tags below
    variations = variationPolicyModel
                   .where(experiment_id: exp_ids)

    return exp_ids, variations, variationsDocHash, experimentsDocHash
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

      exp_ids,
      variations,
      variationsDocHash,
      experimentsDocHash = self.querySearch(query, variationPolicyModel)

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

      profile_ids = Profile
                      .tagged_with(industries)
                      .pluck(:id).uniq

      profile_exp_ids = experimentPolicyModel
                          .where(profile_id: profile_ids)
                          .pluck(:id)

      variations = (variations || variationPolicyModel)
                     .includes(:experiment)
                     .includes(:renderables)
                     .where(experiment_id: profile_exp_ids)

    end

    # variations give us experiments
    # exp_ids give us the ordering
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

#
# PG_SEARCH Notes Difficulties + Errors with highlighting
#
# 1. pg_search_scope: highlighting completely breaks when search scope
# uses "associated_against" in any form.  example: Profile search
# scope: assoicated_against industry_tags breaks on run
# "..with_pg_search_highlight".  Highlighting is unavailable when
# using pg_search_scope
#
# 2. pg_search_scope: highlighted result doesn't differentiate between
# multiple attributes; e.g the call to pg_search_highlight against
# [:domain, :name] returns a single line of merged content - the
# search content has no structure, it's a search of the index.
#
#
# highlight configuration is in config/initializers/pg_search.rb
#
