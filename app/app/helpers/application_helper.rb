module ApplicationHelper

  def format_subscription_date(subscription_id)
    begin
      stripe_subscription = Stripe::Subscription.retrieve(subscription_id)
      time = Time.at(stripe_subscription.current_period_end)
      puts time
      return time.to_datetime.strftime('%B %-d')
    rescue
      return nil
    end
  end

  def format_expvar_date(utcDate)

    #strftime eg: Jan 8, '21
    output = utcDate.strftime("%b %e, '%y")

    if Time.current - 3.days < utcDate
      output = distance_of_time_in_words_to_now(utcDate) + " ago"
    end

    return output
  end

  def format_profile_date(utcDate)
    output = utcDate.strftime("%b %e, %y")

    if Time.current - 3.days < utcDate
      output = '<i class="far fa-lightbulb"></i>'.html_safe
    end
    return output
  end
end
