module ProfilesHelper

  MAX_LEN = 200

  def profile_description(profile, attributeHighlightHash)

    # search/filter: return highlighted results
    # change description to center around search result
    if !attributeHighlightHash.empty?
      return expvar_highlight_for(profile, attributeHighlightHash,
                                  :description,
                                  profile.description)
    end

    # empty
    return nil unless profile.description?

    # used on profiles#index
    #
    # find nearest sentence to MAX_LEN chars
    # want to generate a summary snippet ~ MAX_LEN length -
    # that's shorter than profile#show; and also *not* a search
    # snippet centered about the search term.
    #
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

    anchor = !options[:anchor].nil? ? "##{options[:anchor]}" : ''

    #name text -> url safe
    slug = profile[:company_name].parameterize

    #
    # use id since profile param isn't necessarily active record obj
    #
    return "#{profile_path(profile[:id])}/#{slug}#{anchor}"
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
