class IndustriesController < ApplicationController

  def index

    if (params[:query])
      tags = params[:query]
      @tags = ActsAsTaggableOn::Tag
                .named_like(tags)
                .for_context('industry_tag')

      # autocomplete
      if (params[:partial])
       render partial: 'tags'
      end
      return
    end

    num = ActsAsTaggableOn::Tag.count
    @tags = ActsAsTaggableOn::Tag
              .most_used(num)
              .for_context('industry_tag')
              .limit(1000)

  end

end
