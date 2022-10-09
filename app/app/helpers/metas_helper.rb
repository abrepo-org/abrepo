#
# default metas hardcoded for now
#
module MetasHelper
  # override defaults by passing as params
  def seo_meta_tags(options = {})
    safe_join([
                seo_meta_title_tags(title: options[:title]),
                seo_meta_description_tags(description: options[:description]),
                seo_meta_image_tags(image: options[:image])
              ], "\n")
  end

  # used for both html title tag and meta
  # content_for :title set in view, is prioritized and used for meta
  # (it can be overloaded in seo_meta_tags, but aim for consistency)
  def content_for_title
    default = "The A/B Test Search Engine - Find Your Best A/B Test | #{Rails.application.config.app_title}"
    content_for?(:title) ? content_for(:title) : default
  end


  def seo_meta_title_tags(meta = {})
    # this should really be set by content_for :title
    safe_join(
      [
        tag("meta", {content: meta[:title] || content_for_title, property: "og:title"}),
        tag("meta", {content: meta[:title] || content_for_title, property: "twitter:title"})
      ], "\n")
  end

  def seo_meta_description_tags(meta = {})
    # override on profiles, tags, etc
    default = "ABrepo is your A/B test search engine. Instantly search, monitor, and display A/B tests from leading companies."

    safe_join([
                tag("meta", {content: meta[:description] || default, name: "description"}),
                tag("meta", {content: meta[:description] || default, property: "og:description"}),
                tag("meta", {content: meta[:description] || default, property: "twitter:description"})

              ], "\n")
  end

  def seo_meta_image_tags(meta = {})
    default = image_url( asset_pack_path('media/images/ABrepo-og-image.png') )
    safe_join(
      [
        tag("meta", {content: meta[:image] || default, property: "og:image"}),
        tag("meta", {content: meta[:image] || default, property: "twitter:image"}),
        tag("meta", {content: "summary_large_image", name: "twitter:card"})
      ], "\n")
  end

end
