# coding: utf-8
module SearchHelper

  def tag_link_for(query, tags, industries)
    search_input_text = Search.buildSearchQuery(query, tags, industries)
    url_for(params: { query: search_input_text })
  end

end
