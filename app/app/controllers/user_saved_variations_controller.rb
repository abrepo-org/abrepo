class UserSavedVariationsController < ApplicationController
  before_action :authenticate_user!

  def create

    @uv = current_user.user_saved_variations.find_by_variation_id(params[:id])

    if (@uv)
      @uv.update_attribute(:deleted, !@uv.deleted)
    else
      @uv = current_user.user_saved_variations.create(variation_id: params[:id])
    end

    status = !@uv.deleted

    respond_to do |format|
      format.json  { render json: {saved: status}  }
    end
  end

  def index
  end


end
