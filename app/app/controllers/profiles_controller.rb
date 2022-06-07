class ProfilesController < ApplicationController
  include UserSavedVariationsHash

  def index
    @query = params[:query].blank? ? nil : params[:query]
    @industries = [* params[:industries] ]

    @profiles = policy_scope(Profile)
                  .where.not(experiments: { profile_id: nil})
                  .order(updated_at: :desc)

    if @query
      @profiles = @profiles.search_company(@query)
    end

    unless @industries.empty?

      profile_ids = @profiles.pluck(:id).uniq

      @profiles = @profiles
                    .tagged_with(@industries)


      # ISSUE: ordering of results
      # query sets a ranking
      # if there is no query we have no idea what the "order" should be
      # even if we have a way to order results, we don't know what that order should be
      # when there's no query
      # so back and forth things can move around
      #
      #.joins("JOIN unnest('{#{profile_ids.join(',')}}'::int[]) WITH ORDINALITY t(profile_id, ord) USING (profile_id)")
      #.reorder('t.ord')

    end

    if (@profiles.length > 0)
      @pagy, @profiles = pagy(@profiles, items: 20)
    end


    #sidebar
    @top_profiles = Sidebar.top_profiles

    @top_industries = Sidebar.top_industries

    # featured experiments
    # choose experiments:
    # 1. featured: true -> defer for now
    # 2. or topN of calcRank
    @featured_experiments = Experiment.calcRank.limit(5)


    if params[:partial]
      respond_to do |format|
        format.html { render partial: 'profile_cards' }
      end
    end
  end


  def show

    @profile = policy_scope(Profile)
                 .find_by_id(params[:id])

    raise ActionController::RoutingError.new('Not Found') if (@profile.nil?)

    # redirect; serve only to proper parameterized slug url (/:id/slug)
    pname = @profile.company_name.parameterize
    redirect_to "/profiles/#{@profile.id}/#{pname}" unless params[:name] == pname

    @experiments = policy_scope(@profile.experiments)
                     .includes([:source_vendor,
                                variations: [:renderables, :tag, :page_tag]
                               ])
                     .order(created_at: :desc)

    @num_variations  = []
    @tag_counts = []
    @featured_experiments = []
    @user_saved_variations = []

    if (@experiments.length > 0)

      @num_variations = policy_scope(Variation)
                          .where(experiment_id: @experiments)
                          .select('experiment_id, COUNT(variations.id) as count')
                          .group('experiment_id')
                          .pluck('variations.count')
                          .sum


      @pagy, @experiments = pagy(@experiments)

      @experiments = obfuscate_from(@experiments,
                                    num_given_pagination(@experiments.length)) if not subscribed_or_moderator

      @tag_counts = Sidebar.tag_counts_by_profile_id(@profile.id)

      @featured_experiments = policy_scope(Experiment)
                                .calcRank
                                .limit(5)

      @user_saved_variations = user_saved_variations_hash
    end
  end

end
