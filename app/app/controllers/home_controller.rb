class HomeController < ApplicationController

  # home page feeed
  # 1. date: sort by "new", add pagination
  # 2. quality + date: initially calculate a quality score vs recency - have a fixed list (top 100), then link to sort by new - how Stack overflow does it

  # 3. (quality, visitor, date): add visits/clicks score input; promote? wouldn't we want more popular tests? demote personal, promote global?
  # 4. quality score is combination of commentary exists, summaries, tags - the more "informative" and complete an experiment is, the higher score it gets.
  # 5. (quality, visitor, date, affinity): affinity some score of personal preference

  def index
    @experiments = policy_scope( Experiment.calcRank )
    @pagy, @experiments = pagy(@experiments)

    # topcompanies
    # sum of a companies calcscores
    #[[:id, :company_name] => calcscoreRank, ...]
    @top_profiles = Profile
                      .joins(:experiments)
                      .group(:id, :company_name)
                      .order('sum_experiments_calcscore_pow_select_extract_epoch_from_current desc')
                      .limit(5)
                      .sum('experiments.calcscore / (POW(( ( (SELECT EXTRACT(EPOCH FROM CURRENT_TIMESTAMP(0))) - (SELECT EXTRACT(EPOCH FROM experiments.created_at)) ) / 3600) + 2, 1.8))')

    # top industries
    # sum of an industry companies calcscores
    @top_industries = ActsAsTaggableOn::Tag
                        .find_by_sql("SELECT tags.id, tags.name, SUM(experiments.calcscore / (POW(( ( (SELECT EXTRACT(EPOCH FROM CURRENT_TIMESTAMP(0))) - (SELECT EXTRACT(EPOCH FROM experiments.created_at)) ) / 3600) + 2, 1.8))) as score FROM tags INNER JOIN taggings ON taggings.tag_id = tags.id INNER JOIN profiles ON taggings.taggable_id = profiles.id INNER JOIN experiments ON experiments.profile_id = profiles.id WHERE taggings.taggable_type = 'Profile' GROUP BY tags.id ORDER BY score DESC LIMIT 10")
                        .map{ |tag| {id: tag.id, name: tag.name, score: tag['score']} }

    # featured experiments
    # choose experiments:
    # 1. featured: true -> defer for now
    # 2. or topN of calcRank
    @featured_experiments = Experiment.calcRank.limit(5)

  end
end
