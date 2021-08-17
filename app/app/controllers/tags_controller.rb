class TagsController < ApplicationController

  def index

    if (params[:query])
      tags = params[:query]
      @tags = (ActsAsTaggableOn::Tag.named_like(tags).for_context('tag') +
               ActsAsTaggableOn::Tag.named_like(tags).for_context('page_tag'))
                .flatten

      # autocomplete
      if (params[:partial])
        render partial: 'tags'
      end
      return
    end

    num = ActsAsTaggableOn::Tag.count

    @tags = ActsAsTaggableOn::Tag
              .most_used(num)
              .joins(:taggings)
              .where(["#{ActsAsTaggableOn.taggings_table}.context IN (?)", ['tag', 'page_tag'] ])
              .select("DISTINCT #{ActsAsTaggableOn.tags_table}.*")
  end



end
