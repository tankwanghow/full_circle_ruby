module SharedHelpers
  def docnolize val, prepend=''
    prepend + ("%07d" % val) if val
  end

  def prev_close_date date
    close_date = Date.new date.to_date.year, ClosingMonth, ClosingDay
    close_date >= date.to_date ? close_date.years_ago(1) : close_date
  end
end