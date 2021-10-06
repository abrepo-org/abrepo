class UserSavedVariationsController < ApplicationController
  include UserSavedVariationsHash
  before_action :authenticate_user!

  def create

    @uv = current_user.user_saved_variations.find_by_variation_id(params[:id])

    if (@uv)
      @uv.update_attribute(:deleted, !@uv.deleted)
    else
      @uv = current_user.user_saved_variations.create(variation_id: params[:id])
    end

    status = @uv.deleted

    respond_to do |format|
      format.json  { render json: {saved: status}  }
    end
  end

  def index

    @experiments = Experiment
                     .joins(variations: { user_saved_variations: :variation})
                     .where('user_saved_variations.deleted': false,
                            'user_saved_variations.user_id': current_user)
                     .distinct

    @experiments = policy_scope( @experiments )
    @pagy, @experiments = pagy(@experiments)

    # sidebar
    @top_profiles = Sidebar.top_profiles

    @top_industries = Sidebar.top_industries

    # save hash indicator
    @user_saved_variations = user_saved_variations_hash
  end


end
