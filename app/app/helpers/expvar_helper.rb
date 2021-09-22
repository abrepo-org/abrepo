module ExpvarHelper

  # determines if variation-view is the same variation (should be hidden) with a
  # different view, or is a standalone variation
  # TODO: assumes variations sorted by vendor_id - set sort in imports?

  def isVarDupeView(variations, index)
    return false if index == 0
    return variations[index].vendor_id == variations[index-1].vendor_id
  end

  def pageURLHelper(variation)
    variation.renderables.where(control:false).first ?
      variation.renderables.where(control:false).first.renderedURL.sub(/https?\:\/\//, '') :
      ''
  end
end
