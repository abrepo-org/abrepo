module UserSavedVariationsHelper
  def calc_usv_cache_key(usv, experiment)
    experiment.variations.map{ |variation| "#{variation.id}-#{usv[variation.id]}" }.join("/")
  end
end
