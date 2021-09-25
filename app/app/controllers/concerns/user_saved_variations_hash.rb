module UserSavedVariationsHash
  extend ActiveSupport::Concern
  
  def user_saved_variations_hash
    saved_variations = {}

    if user_signed_in? && current_user.user_saved_variations
      current_user.user_saved_variations.each do |usv|
        saved_variations[ usv['variation_id'] ] = !usv['deleted']
      end
    end

    return saved_variations
  end

end
