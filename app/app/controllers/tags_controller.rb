class TagsController < ApplicationController

  def index

    if (params[:tags])
      tags = params[:tags]
      @tags = (ActsAsTaggableOn::Tag.named_like(tags).for_context('tag') +
               ActsAsTaggableOn::Tag.named_like(tags).for_context('page_tag'))
                .flatten

      return render json: @tags
    end

    num = ActsAsTaggableOn::Tag.count

    @tags = ActsAsTaggableOn::Tag
              .most_used(num)
              .joins(:taggings)
              .where(["#{ActsAsTaggableOn.taggings_table}.context IN (?)", ['tag', 'page_tag'] ])
              .select("DISTINCT #{ActsAsTaggableOn.tags_table}.*")

    render json: @tags
  end

end
