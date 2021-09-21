class Sidebar
  include Pundit

  def self.top_profiles
    # topcompanies
    # sum of a companies calcscores
    #[[:id, :company_name] => calcscoreRank, ...]
    Profile
      .joins(:experiments)
      .group(:id, :company_name)
      .order('sum_experiments_calcscore_pow_select_extract_epoch_from_current desc')
      .limit(5)
      .sum('experiments.calcscore / (POW(( ( (SELECT EXTRACT(EPOCH FROM CURRENT_TIMESTAMP(0))) - (SELECT EXTRACT(EPOCH FROM experiments.created_at)) ) / 3600) + 2, 1.8))')

  end

  def self.top_industries

    # top industries
    # sum of an industry companies calcscores
    ActsAsTaggableOn::Tag
      .find_by_sql("SELECT tags.id, tags.name, SUM(experiments.calcscore / (POW(( ( (SELECT EXTRACT(EPOCH FROM CURRENT_TIMESTAMP(0))) - (SELECT EXTRACT(EPOCH FROM experiments.created_at)) ) / 3600) + 2, 1.8))) as score FROM tags INNER JOIN taggings ON taggings.tag_id = tags.id INNER JOIN profiles ON taggings.taggable_id = profiles.id INNER JOIN experiments ON experiments.profile_id = profiles.id WHERE taggings.taggable_type = 'Profile' GROUP BY tags.id ORDER BY score DESC LIMIT 10")
      .map{ |tag| {id: tag.id, name: tag.name, score: tag['score']} }

  end

end
