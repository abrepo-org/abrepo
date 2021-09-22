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

    # autocomplete
    if (params[:partial])
      respond_to do |format|
        format.html { render partial: 'industries' }
      end
    end
  end

end
