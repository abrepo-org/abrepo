class Sidebar
  include Pundit

  # topcompanies
  # sum of a companies calcscores
  #[[:id, :company_name] => calcscoreRank, ...]
  def self.top_profiles

    profiles = Profile
                 .joins(:experiments)
                 .where(experiments: { published: true })
                 .group(:id, :company_name, :updated_at)
                 .order('sum_experiments_calcscore_pow_select_extract_epoch_from_current desc')
                 .limit(5)
                 .sum(%{
        experiments.calcscore /
        (POW(( ( (SELECT EXTRACT(EPOCH FROM CURRENT_TIMESTAMP(0))) -
        (SELECT EXTRACT(EPOCH FROM experiments.created_at)) ) / 3600) + 2, 1.8))
      })

    profiles.map{ |p| {id: p[0][0], company_name: p[0][1], updated_at: p[0][2] } }

  end


  # top industries
  # sum of an industry companies calcscores
  def self.top_industries

    sql = %{
        SELECT tags.id, tags.name,
        SUM(experiments.calcscore /
        (POW(( ( (SELECT EXTRACT(EPOCH FROM CURRENT_TIMESTAMP(0))) -
        (SELECT EXTRACT(EPOCH FROM experiments.created_at)) ) / 3600) + 2, 1.8))) as score
        FROM tags
        INNER JOIN taggings ON taggings.tag_id = tags.id
        INNER JOIN profiles ON taggings.taggable_id = profiles.id
        INNER JOIN experiments ON experiments.profile_id = profiles.id
        WHERE taggings.taggable_type = 'Profile' AND experiments.published = true
        GROUP BY tags.id
        ORDER BY score DESC
        LIMIT 10
    }

    # score: tag['score'] - removed for caching
    ActsAsTaggableOn::Tag
      .find_by_sql(sql)
      .map{ |tag| {id: tag.id, name: tag.name} }

  end

  def self.top_tags
    # inner query groups number of taggings id per variation's vendor_id
    # outer query groups by tag (totals) id and counts those instances
    #
    # for multi-page variations, there are typically multiple views
    # rendered per variation. Our goal to count tags per single
    # "variation" group, indicated by a shared variation.vendor_id.
    #
    # so our outer query groups counts each vendor_id tag instance
    #

    sql = %{
        SELECT totals.id, totals.name, COUNT(totals.id) FROM
            (SELECT tags.id, variations.vendor_id, tags.name
             FROM tags
             INNER JOIN taggings ON taggings.tag_id = tags.id
             INNER JOIN variations ON taggings.taggable_id = variations.id
             WHERE taggings.taggable_type = 'Variation' AND variations.published = true
             GROUP BY tags.id, variations.vendor_id) as totals
         GROUP BY totals.id, totals.name
         ORDER BY count DESC
         LIMIT 10
    }

    ActsAsTaggableOn::Tag
      .find_by_sql(sql)
      .map{ |tag| {id: tag.id, name: tag.name, count: tag['count']} }


    #
    # Previous Company tags and counts - this is across all
    # variation-views (not grouped by vendor ids) so it overcounts
    # tags on multi-page variations
    #

    # ActsAsTaggableOn::Tag
    #   .joins(:taggings)
    #   .select('tags.id, tags.name, COUNT(taggings.id) as count')
    #   .group('tags.id, tags.name')
    #   .where(taggings: { taggable_type: 'Variation',
    #                          #taggable_id: policy_scope(Variation)
    #                      taggable_id: Variation
    #                        .joins(:experiment)
    #                        .where({experiment: {profile_id: profile.id}})
    #                    })
    #   .order('tags.count desc')
    #   .limit(10)
    #   .map{ |tag| { id: tag[:id], name: tag[:name], count: tag['count'] } }

  end

  #
  # same as top tags, but filtered for specific profile
  #
  def self.tag_counts_by_profile_id(profile_id)

    sql = %{
        SELECT totals.id, totals.name, COUNT(totals.id) FROM
            (SELECT tags.id, variations.vendor_id, tags.name
             FROM tags
             INNER JOIN taggings ON taggings.tag_id = tags.id
             INNER JOIN variations ON taggings.taggable_id = variations.id
             INNER JOIN experiments ON experiments.id = variations.experiment_id
             WHERE taggings.taggable_type = 'Variation' AND experiments.profile_id = ?
                   AND experiments.published = true
                   AND variations.published = true
             GROUP BY tags.id, variations.vendor_id) as totals
         GROUP BY totals.id, totals.name
         ORDER BY count DESC
         LIMIT 10
    }

    ActsAsTaggableOn::Tag
      .find_by_sql([sql, profile_id])
      .map{ |tag| {id: tag.id, name: tag.name, count: tag['count']} }

  end

end
