module VariationsHelper

  def variation_path_slug(variation, options = {})
    anchor = options[:anchor] ? "##{options[:anchor]}" : ''
    slug = variation[:summary_name].parameterize
    return "/variations/#{variation[:id]}/#{slug}#{anchor}"
  end

end
