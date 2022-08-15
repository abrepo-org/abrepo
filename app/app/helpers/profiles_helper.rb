module ProfilesHelper

  MAX_LEN = 200

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

    # search/filter: return highlighted results
    if descriptions_map && descriptions_map[profile.id]
      return sanitize descriptions_map[profile.id]
               .pg_search_highlight

    end

    # empty
    return nil unless profile.description?

    # find nearest sentence to MAX_LEN chars
    # used on profiles#index
    # 1. find positions of 'period' in description
    # 2. find position nearest to MAX_LEN (shortest distance)
    # 3. return substring from 0 to that position + 1 (for period)
    res = profile.description.enum_for(:scan, /(?=\.)/).map do
      Regexp.last_match.offset(0).first
    end

    index = res[ res.map { |r| (r - MAX_LEN).abs }.each_with_index.min[1] ]
    return profile.description[0, index + 1]


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
