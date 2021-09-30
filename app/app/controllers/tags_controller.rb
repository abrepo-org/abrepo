class TagsController < ApplicationController

  def index

    unless params[:query].blank?

      tags = params[:query]
      @tags = (ActsAsTaggableOn::Tag.named_like(tags).for_context('tag') +
               ActsAsTaggableOn::Tag.named_like(tags).for_context('page_tag'))
                .flatten
    else

      num = ActsAsTaggableOn::Tag.count

      @tags = ActsAsTaggableOn::Tag
                .most_used(num)
                .joins(:taggings)
                .where(["#{ActsAsTaggableOn.taggings_table}.context IN (?)", ['tag', 'page_tag'] ])
                .select("DISTINCT #{ActsAsTaggableOn.tags_table}.*")

    end


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
