module IndustriesHelper

  def calc_tagged_experiments(tag)
    Profile
      .includes(:experiments)
      .tagged_with(tag.name)
      .inject(0) { |sum, profile| sum + profile.experiments.length }
  end

end
