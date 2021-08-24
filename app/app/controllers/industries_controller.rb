class IndustriesController < ApplicationController

  def index

    if (params[:query])
      industries = params[:query]
      @industries = ActsAsTaggableOn::Tag
                      .named_like(industries)
                      .for_context('industry_tag')

      # autocomplete
      if (params[:partial])
        respond_to do |format|
          format.html { render partial: 'industries' }
          format.json { render json: @industries }
        end
      end
      return
    end

    num = ActsAsTaggableOn::Tag.count
    @industries = ActsAsTaggableOn::Tag
              .most_used(num)
              .for_context('industry_tag')
              .limit(1000)

  end

end
