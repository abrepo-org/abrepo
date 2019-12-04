class TestModelsController < ApplicationController
  def test

    @test = {test:'hi'}

=begin

## make notes
rails g model experiment name:string profile:belongs_to
how to annotate
1


profile

experiment
  campaign
  variation
    action
    renderable
  audience
  
  crawl?

vendor


=end
    


    respond_to do |format|
      format.html { render plain: "OK" }
    end
    
  end
end
