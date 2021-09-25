class UserSavedVariationsController < ApplicationController
  before_action :authenticate_user!

  def create
    status = false
    puts current_user.id, params[:id]
    @uv = current_user.user_saved_variations.build({variation_id: params[:id]})
    puts @uv.inspect

    # if exists set delete false / else true
    # has_many, dependent: :destroy
    #status = true if @uv.save

    #status = true


    respond_to do |format|
      format.json  { render json: {saved: status}  }
    end
  end

  def index
  end


end
