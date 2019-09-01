Holidays.between(Date.civil(2013, 1, 1), 2.years.from_now, :gb_eng, :observed).map do |holiday|
  BusinessTime::Config.holidays << holiday[:date]
end

BusinessTime::Config.end_of_workday = "11:59 pm"
