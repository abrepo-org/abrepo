# coding: utf-8
module SearchHelper

  def tag_link_for(query, tags, industries)
    search_input_text = Search.buildSearchQuery(query, tags, industries)
    return url_for(params: { query: search_input_text }) unless search_input_text.blank?
    return nil
  end

  # see search.rb
  # highlightHash = {
  #   experiment: {
  #     summary_name: {id => experiment instance }
  #     audience_name: {id => experiment instance }
  #   },
  #   variation: {
  #     summary_name: {id => variation instance }
  #   }
  # }
  #
  # ex call:
  # expvar_highlight_for(experiment, @expvarHighlightHash[:experiment], :summary_name, "no name")
  # expvar_highlight_for(profile, @profileHighlightHash[:profile], :company_name, profile.domain)
  #
  def expvar_highlight_for(instance, attributeHighlightHash, field_name, default_value)

    if !attributeHighlightHash.empty? &&
       attributeHighlightHash[field_name].key?(instance.id)
      return sanitize attributeHighlightHash[field_name][instance.id].pg_search_highlight
    end

    return instance[field_name].blank? ? default_value : instance[field_name]
  end
end
