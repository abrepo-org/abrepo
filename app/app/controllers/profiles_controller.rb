class ProfilesController < ApplicationController
  include UserSavedVariationsHash

  def index

    @query, @tags, @industries = Search.extractSearchParams(params[:query])

    @profiles = []
    @profileHighlightHash = {
      profile: {}
    }

    unless @query.empty?

      # NB: we're not ordering by rank - see if we can get by with
      # just notion of "filter" vs "search" + relevance ranking.
      # Maybe change later if its bad.
      @profiles, @profileHighlightHash = Profile
                                           .search_company(@query.join(" "),
                                                           policy_scope(Profile))
    else

      #
      # Default ordering attempt 2: "companies with most tags"
      # prioritize by "popularity" - most variations, and most tags
      #
      # Previously ordered by most recent date, which tended toward unknown,
      # "uninteresting" companies, albeit new. Since in demo mode, ordering by
      # "tag volume" displays more established, stronger branded companies
      #

      profile_ids = policy_scope(Profile)
                      .select('profiles.id, COUNT(taggings.id) AS total_tag_count')
                      .joins(experiments: { variations: :taggings })
                      .group('profiles.id')
                      .order('total_tag_count DESC')
                      .map(&:id)

      @profiles = policy_scope(Profile)
                    .includes(:industry_tag)
                    .where(id: profile_ids)
                    .order(Arel.sql("position(profile_id::text in '#{profile_ids.join(',')}')"))
    end


    # filters tags + industries
    unless @tags.empty?

      profile_tag_ids = Variation
        .joins(experiment: :profile)
        .tagged_with(@tags)
        .group("profiles.id")
        .count.map{ |profile_id, count| profile_id}
        .uniq

      @profiles = @profiles.where(id: profile_tag_ids)
    end

    unless @industries.empty?
      @profiles = Profile
                    .where(id: @profiles)
                    .tagged_with(@industries)
    end

    if (@profiles.length > 0)
      @pagy, @profiles = pagy(@profiles, items: 20,
                              params: ->(params) {
                                return params.except(:query, :partial) if params[:query].blank?
                                return params.except(:partial)
                              })
    end


    #sidebar
    @top_profiles = Sidebar.top_profiles

    @top_industries = Sidebar.top_industries

    # featured experiments
    # choose experiments:
    # 1. featured: true -> defer for now
    # 2. or topN of calcRank
    @featured_experiments = policy_scope(Experiment).calcRank(5)


    if params[:partial]
      respond_to do |format|
        format.html { render partial: 'profile_cards' }
      end

    end
  end


  def show

    @profile = policy_scope(Profile).where(id: params[:id]).first

    raise ActionController::RoutingError.new('Not Found') if @profile.nil?
    # only allow mod to see empty profiles
    if (!user_signed_in? or !current_user.moderator?) and @profile.experiments.empty?
      raise ActionController::RoutingError.new('Not Found')
    end

    # redirect; serve only to proper parameterized slug url (/:id/slug)
    pname = @profile.company_name.parameterize
    redirect_to "/profiles/#{@profile.id}/#{pname}" unless params[:name] == pname

    # reuse shared/_expvar_ * views
    @expvarHighlightHash = {
      experiment: {
        summary_name: {},
        audience_name: {},
        domain: {}
      },
      variation: {
        summary_name: {}
      }
    }

    @experiments = policy_scope(@profile
                                  .experiments
                                  .includes(:source_vendor, :variations)
                                  .order(created_at: :desc)) #experiments.created_at

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

    @num_variations  = []
    @tag_counts = []
    @featured_experiments = []
    @related_companies = []
    @user_saved_variations = []

    if (@experiments.length > 0)

      @num_variations = policy_scope(Variation)
                          .where(experiment_id: @experiments)
                          .pluck(:id)
                          .length

      @pagy, @experiments = pagy(@experiments)

      @experiments = obfuscate_from(@experiments,
                                    num_given_pagination(@experiments.length)) if not subscribed_or_moderator
      @tag_counts = Sidebar.tag_counts_by_profile_id(@profile.id)

      @featured_experiments = policy_scope(Experiment)
                                .includes(:profile)
                                .calcRank(5)

      @related_companies = @profile.get_related_companies(7)

      @user_saved_variations = user_saved_variations_hash
    end
  end

end
