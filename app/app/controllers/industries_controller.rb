class IndustriesController < ApplicationController

  def index

    if (params[:tags])
      tags = params[:tags]
      @tags = ActsAsTaggableOn::Tag.named_like(tags).for_context('industry_tag')
      return render json: @tags
    end

    num = ActsAsTaggableOn::Tag.count
    @tags = ActsAsTaggableOn::Tag.most_used(num)
              .for_context('industry_tag').limit(1000)

    render json: @tags
  end

end
