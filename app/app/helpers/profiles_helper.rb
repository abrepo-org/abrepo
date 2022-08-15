module ProfilesHelper

  def profile_company_name(profile, names_map, domains_map)
    if names_map && names_map[profile.id]
      return sanitize names_map[profile.id].pg_search_highlight
    end

    if profile.company_name
      return profile.company_name
    end

    if domains_map && domains_map[profile.id]
      return sanitize domains_map[profile.id].pg_search_highlight
    end

    return profile.domain
  end


  def profile_description(profile, descriptions_map)
    if descriptions_map && descriptions_map[profile.id]
      return sanitize descriptions_map[profile.id]
               .pg_search_highlight
               .split(".")
               .first + "."
    end

    #TODO: change to fixed char length
    return sanitize profile.description if profile.description
  end

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
