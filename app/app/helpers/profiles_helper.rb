module ProfilesHelper

  def profile_industry_filter_links(params, industries)
    industries.map { |industry|

      new_params = {
        industries: [industry]
      }

      link_to(industry, url_for(params: new_params))

    }.join(", ").html_safe
  end

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
