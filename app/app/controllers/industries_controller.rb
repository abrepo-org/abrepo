class IndustriesController < ApplicationController

  def index

    unless params[:query].blank?

      industries = params[:query]
      @industries = ActsAsTaggableOn::Tag
                      .named_like(industries)
                      .for_context('industry_tag')
    else

      num = ActsAsTaggableOn::Tag.count
      @industries = ActsAsTaggableOn::Tag
                      .most_used(num)
                      .for_context('industry_tag')
                      .limit(1000)
    end

    # calc_recency

    #calc_recency-> {tag_id: num}
    @DAYS = 14
    @recency_hash_by_id = {}
    ActsAsTaggableOn::Tagging
      .joins(:tag)
      .select("tag_id, count(tag_id) as count")
      .where('taggings.created_at > ?', @DAYS.days.ago)
      .where(["#{ActsAsTaggableOn.taggings_table}.context IN (?)", ['industry_tag'] ])
      .group(:tag_id)
      .each{ |t| @recency_hash_by_id[ t[:tag_id] ] = t[:count] }

    #profiles -> {industry_tag_id: [Profiles]}
    @profile_hash_by_id = Profile.build_tag_examples(current_user,
                                                     policy_scope(Profile),
                                                     @industries) unless request.format == "application/json"

    # autocomplete
    if (params[:partial])
      respond_to do |format|
        format.html { render partial: 'industries' }
        format.json {
          render json: {
                   results: @industries.slice(0, 11).map{ |k| { name: k.name }},
                   total: ActsAsTaggableOn::Tag.for_context('industry_tag').count
                 }
        }

      end
    end
  end

end
