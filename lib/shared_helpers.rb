module SharedHelpers
  def docnolize val, prepend=''
    prepend + ("%07d" % val) if val
  end

  def prev_close_date date
    close_date = Date.new date.to_date.year, ClosingMonth, ClosingDay
    close_date >= date.to_date ? close_date.years_ago(1) : close_date
  end

  def diff_month date2, date1
    (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month)
  end

  def can_save? date2, date1
    diff_month(date2, date1) <= 1 || User.current.is_manager
  end
end
