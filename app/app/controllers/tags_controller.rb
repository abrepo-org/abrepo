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
    @tags = ActsAsTaggableOn::Tag.most_used(num).limit(1000)

    render json: @tags
  end

end
