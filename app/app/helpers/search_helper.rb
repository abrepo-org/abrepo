# coding: utf-8
module SearchHelper

  def tag_link_for(query, tags, industries)

    url_for(controller: 'search',
            action: 'show',
            params: {
              utf8: params[:utf8],
              query: query,
              tags: tags,
              industries: industries
            })

  end
end
