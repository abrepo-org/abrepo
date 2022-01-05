module ExpvarHelper

  # for moderator only, label Pub: true/false if published
  def is_published?(expvar)
    if user_signed_in? && current_user.moderator?
      klass = expvar.published ? "is-size-7" : "is-size-7 has-text-danger"
      return "<span class='#{klass}'>[Pub: #{expvar.published?}]</span>".html_safe
    end
  end

  def obfuscate_link_to(obfuscated, path, &block)
    path = "#" if obfuscated
    link_to(path, class: obfuscated ? "obfuscated-link" : "" ) do
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
    variations.where(vendor_id: vendor_id).count
  end

  def pageURLHelper(variation)
    variation.renderables.where(control:false).first ?
      variation.renderables.where(control:false).first
        .obfuscate
        .renderedURL.sub(/https?\:\/\//, '') :
      ''
  end
end
