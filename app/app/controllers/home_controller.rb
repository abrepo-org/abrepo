class HomeController < ApplicationController
  include UserSavedVariationsHash

  # home page feed plan
  # 1. initial step: date: sort by "new", add pagination
  #
  # 2. quality + date: calculate a quality score vs recency: Experiment.calcRank
  #
  # 3. (quality, visitor, date): add visits/clicks score input;
  # promote? wouldn't we want more popular tests? demote personal,
  # promote global?
  #
  # 4. quality score is combination of commentary exists, summaries,
  # tags - the more "informative" and complete an experiment is, the
  # higher score it gets.
  #
  # 5. (quality, visitor, date, affinity): affinity some score of
  # personal preference

  def index

    @expvarHighlightHash = {
      experiment: {},
      variation: {}
    }

    #
    # interleave experiment order:
    # loop each profile ordered by total tag count
    # pop out experiments in order until profile / experiments are exhausted
    #
    # want to show experiments from "popular" profiles, but also novelty
    # by rotating through each profile
    # contrast previously ordering by date, often get uninteresting experiments / companies
    #

    profile_ids = policy_scope(Profile).ids_by_total_tag_counts

    experiment_ids = Experiment.interleave_order(profile_ids)

    @experiments = policy_scope(Experiment)
                     .includes(:source_vendor, :profile, :variations)
                     .where(id: experiment_ids)
                     .order(Arel.sql("position(id::text in '#{experiment_ids.join(',')}')"))

    @variations = policy_scope(Variation)
                    .includes(:experiment,
                              :renderables,
                              :tag, :page_tag)
                    .where(experiment_id: @experiments)
                    .order([
                             "variations.verified desc",
                             "variations.created_at desc",
                             "variations.summary_name asc"
                           ])

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
    @featured_experiments = policy_scope(Experiment)
                              .includes(:profile)
                              .calcRank(5)

    @user_saved_variations = user_saved_variations_hash
  end
end
