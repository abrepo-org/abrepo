class TagsController < ApplicationController
  before_action :require_moderator

  def index

    unless params[:query].blank?

      tags = params[:query]

      @tags = ActsAsTaggableOn::Tag
                .joins(:taggings)
                .named_like(tags)
                .where(["#{ActsAsTaggableOn.taggings_table}.context IN (?)", ['tag', 'page_tag'] ])
                .select("DISTINCT #{ActsAsTaggableOn.tags_table}.*")

    else

      num = ActsAsTaggableOn::Tag.count

      @tags = ActsAsTaggableOn::Tag
                .joins(:taggings)
                .most_used(num)
                .where(["#{ActsAsTaggableOn.taggings_table}.context IN (?)", ['tag', 'page_tag'] ])
                .select("DISTINCT #{ActsAsTaggableOn.tags_table}.*")

    end

    #calc_recency-> {tag_id: num}
    @DAYS = 14
    @recency_hash_by_id = {}
    ActsAsTaggableOn::Tagging
      .joins(:tag)
      .select("tag_id, count(tag_id) as count")
      .where('taggings.created_at > ?', @DAYS.days.ago)
      .where(["#{ActsAsTaggableOn.taggings_table}.context IN (?)", ['tag', 'page_tag'] ])
      .group(:tag_id)
      .each{ |t| @recency_hash_by_id[ t[:tag_id] ] = t[:count] }

    #variations -> {tag_id: [variations]}
    @variation_hash_by_id = Variation.build_tag_examples(current_user,
                                                         policy_scope(Variation),
                                                         @tags)


    if params[:partial]
      respond_to do |format|
        format.html { render partial: 'tags' }
        format.json {
          render json: {
                   results: @tags.slice(0, 11).map{ |k| { name: k.name }},
                   total: ActsAsTaggableOn::Tag.for_context('page_tag').count +
                   ActsAsTaggableOn::Tag.for_context('tag').count
                 }
        }
      end
    end
  end


end
