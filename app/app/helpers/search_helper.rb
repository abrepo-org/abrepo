# coding: utf-8
module SearchHelper

  def tag_link_for(query, tags, industries)
    search_input_text = Search.buildSearchQuery(query, tags, industries)
    return url_for(params: { query: search_input_text }) unless search_input_text.blank?
    return nil
  end

end
