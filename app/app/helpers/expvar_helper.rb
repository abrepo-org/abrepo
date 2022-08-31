module ExpvarHelper

  # for moderator only, label Pub: true/false if published
  def is_published?(expvar)
    if user_signed_in? && current_user.moderator?
      klass = expvar.published ? "is-size-7" : "is-size-7 has-text-danger"
      return "<span class='#{klass}'>[Pub: #{expvar.published?}]</span>".html_safe
    end
  end

  def obfuscate_link_to(obfuscated, path, classes = "", &block)
    path = "#" if obfuscated
    classes = obfuscated ? "#{classes} obfuscated-link" : classes
    link_to(path, class: classes.strip) do
      yield
    end
  end

  # determines if variation-view is the same variation (should be
  # hidden) with a different view, or is a standalone variation
  #
  # is_root and multiple_views -> caret
  # is_root and not multiple_views-> vanilla variation (no caret, no hide)
  # !is_root and multiple_views ->  hidden child
  def set_multiple_views(variations, index)

    num_vendor_id = num_by_vendor_id(variations, index)

    if index == 0
      variations[index].multiple_views = true ? num_vendor_id > 1 : false
      variations[index].is_root = true
      return
    end

    if (variations[index].vendor_id != variations[index-1].vendor_id)

      # first of its (multiple) kind? its a root
      if ( num_vendor_id > 1)
        variations[index].multiple_views = true
        variations[index].is_root = true
      else
        # first of its kind but no children, vanilla standalone variation
        variations[index].multiple_views = false
        variations[index].is_root = true
      end

    end
  end

  def num_by_vendor_id(variations, index)
    vendor_id = variations[index].vendor_id
    return variations
             .filter{ |variation| variation.vendor_id == vendor_id}.length
  end

  def pageURLHelper(variation)

    activeRenderable = variation.renderables
                         .filter{|renderable| !renderable.control }
                         .first

    if (activeRenderable)

      renderedURL = activeRenderable.obfuscate.renderedURL
      renderedURL = URI.parse(renderedURL)

      return [renderedURL.path, renderedURL.query].join

    end

    return ''

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
       !instance.obfuscated? &&
       attributeHighlightHash[field_name].key?(instance.id)
      return sanitize attributeHighlightHash[field_name][instance.id].pg_search_highlight
    end

    return instance[field_name].blank? ? default_value : instance[field_name]
  end
end
