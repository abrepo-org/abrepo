module ProfilesHelper

  def get_related_companies(profile, num)

    results = profile.active_related_companies(num).collect do |company|
      {type: :active, company: company}
    end

    results += profile.inactive_related_companies( num - results.length )
                 .collect do |company|
      {type: :inactive, company: company}
    end

    return results
  end
end
