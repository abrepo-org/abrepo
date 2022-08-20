class ProfilesController < ApplicationController
  include UserSavedVariationsHash

  def index

    @query, @tags, @industries = Search.extractSearchParams(params[:query])

    @profiles = []
    @names_map = {}
    @domains_map = {}
    @descriptions_map = {}

    unless @query.empty?

      @profiles,
      @names_map,
      @domains_map,
      @descriptions_map = Profile
                            .search_company(@query.join(" "),
                                            policy_scope(Profile))
    else

      @profiles = policy_scope(Profile)
                    .includes(:industry_tag)
                    .where.not(experiments: { profile_id: nil})
                    .order(updated_at: :desc)

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
      @profiles = @profiles.tagged_with(@industries)
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

    @profile = policy_scope(Profile)
                 .find_by_id(params[:id])

    raise ActionController::RoutingError.new('Not Found') if @profile.nil?
    # only allow mod to see empty profiles
    if (!user_signed_in? or !current_user.moderator?) and @profile.experiments.empty?
      raise ActionController::RoutingError.new('Not Found')
    end

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
    @related_companies = []
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

      @featured_experiments = policy_scope(Experiment).calcRank(5)

      @related_companies = @profile.get_related_companies(7)

      @user_saved_variations = user_saved_variations_hash
    end
  end

end
