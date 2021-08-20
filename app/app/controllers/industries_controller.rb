class IndustriesController < ApplicationController

  def index

    if (params[:query])
      tags = params[:query]
      @tags = ActsAsTaggableOn::Tag
                .named_like(tags)
                .for_context('industry_tag')

      # autocomplete
      if (params[:partial])
        respond_to do |format|
          format.html { render partial: 'tags' }
          format.json { render json: @tags }
        end
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
