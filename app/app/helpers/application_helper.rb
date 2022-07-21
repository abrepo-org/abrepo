module ApplicationHelper
  include Pagy::Frontend

  def is_layout_full

    tags_index = controller.controller_name == "tags" &&
                 controller.action_name == "index"

    industry_index = controller.controller_name == "industries" &&
                     controller.action_name == "index"

    #devise: /users/edit and /users
    users = controller.controller_name == "checkout"

    return tags_index || industry_index || users
  end

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
    #
    #NB: avoid distance_of_time_in_words_to_now type methods
    #to favor fragment caching
    output = utcDate.strftime("%b %e, '%y")

    return output
  end

  def format_profile_date(utcDate)
    output = utcDate.strftime("%b %e, %y")
    return output
  end
end
