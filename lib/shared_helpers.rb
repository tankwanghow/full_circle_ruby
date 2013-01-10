module SharedHelpers
  def docnolize val, prepend=''
    prepend + ("%07d" % val) if val
  end
end