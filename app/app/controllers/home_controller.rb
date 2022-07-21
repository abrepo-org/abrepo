class HomeController < ApplicationController
  include UserSavedVariationsHash
  before_action :require_moderator

  # home page feeed
  # 1. date: sort by "new", add pagination
  # 2. quality + date: initially calculate a quality score vs recency - have a fixed list (top 100), then link to sort by new - how Stack overflow does it

  # 3. (quality, visitor, date): add visits/clicks score input; promote? wouldn't we want more popular tests? demote personal, promote global?
  # 4. quality score is combination of commentary exists, summaries, tags - the more "informative" and complete an experiment is, the higher score it gets.
  # 5. (quality, visitor, date, affinity): affinity some score of personal preference

  def index

    # added 'calcscoreRank' sql alias breaks pagy - pagy assumes the
    # column exists in database but it's not. (similar with calling
    # pluck(:id) on result set.
    # add a hacky roundabout id query for pagination :\
    experiment_ids = Experiment
                       .calcRank(Experiment.count)
                       .map{ |e| e.id }

    @experiments = policy_scope(Experiment)
                     .where(id: experiment_ids)

    @pagy, @experiments = pagy(@experiments)
    @experiments = obfuscate_from(@experiments, 0) if (not subscribed_or_moderator) &&
                                                      (params[:page] && params[:page].to_i > 2)

    # sidebar
    @top_profiles = Sidebar.top_profiles

    @top_industries = Sidebar.top_industries

    # featured experiments
    # choose experiments:
    # 1. featured: true -> defer for now
    # 2. or topN of calcRank
    @featured_experiments = policy_scope(Experiment).calcRank(5)

    @user_saved_variations = user_saved_variations_hash
  end
end
