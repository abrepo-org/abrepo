module TagsHelper

  def calc_recency_for(tag, days_ago)
    #e.g: 10 new experiments in past week

    ActsAsTaggableOn::Tagging
      .where(tag_id: tag.id)
      .where('created_at > ?', days_ago)
      .count

    # TODO refactor out n+1
    # group_by query, turn to tag_id, count dict
    # @updates = ActsAsTaggableOn::Tagging
    #              .where('created_at > (?)', 14.days.ago)
    #              .group(:tag_id)
    #              .select("COUNT(tag_id), tag_id").count

  end
end
