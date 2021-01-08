module ApplicationHelper

  def format_expvar_date(utcDate)

    #strftime eg: Jan 8, '21
    output = utcDate.strftime("%b %e, '%y")

    if Time.current - 3.days < utcDate
      output = distance_of_time_in_words_to_now(utcDate) + " ago"
    end

    return output
  end

end
