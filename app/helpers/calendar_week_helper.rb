module CalendarWeekHelper
  def week_label(day)
    first_day = day.beginning_of_week
    last_day = day.end_of_week
    if first_day.month == last_day.month
      first_day.strftime('%-d') + "–" + last_day.strftime('%-d %b')
    else
      first_day.strftime('%-d %b') + "–" + last_day.strftime('%-d %b')
    end
  end
end
