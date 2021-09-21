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

    # sidebar
    @top_profiles = Sidebar.top_profiles

    @top_industries = Sidebar.top_industries

    # featured experiments
    # choose experiments:
    # 1. featured: true -> defer for now
    # 2. or topN of calcRank
    @featured_experiments = Experiment.calcRank.limit(5)

  end
end
