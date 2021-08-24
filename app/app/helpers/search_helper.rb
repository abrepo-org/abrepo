# coding: utf-8
module SearchHelper

  def tag_link_for(query, tags, industries)

    url_for(params: {
              query: query,
              tags: tags,
              industries: industries
            })

  end
end
