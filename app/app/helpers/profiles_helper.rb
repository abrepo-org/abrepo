module ProfilesHelper

  def profile_path_slug(profile, options = {})
    anchor = options[:anchor] ? "##{options[:anchor]}" : ''
    slug = profile[:company_name].parameterize
    return "/profiles/#{profile[:id]}/#{slug}#{anchor}"
  end

  def profile_industry_filter_links(params, industries, classes)
    industries.map { |industry|

      new_params = {
        query: "{#{industry}}"
      }

      link_to(industry, url_for(params: new_params), class: classes)

    }.join()
  end

end
