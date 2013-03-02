module ReportsHelper
  def report_filenames
    Dir.glob('app/reports/*_report.rb').map do |t|
      t.chomp('_report.rb').gsub(/app\/reports\//, '')
    end
  end

  def admin_report_filenames
    if current_user.is_admin?
      Dir.glob('app/reports/admin/*_report.rb').map do |t|
        t.chomp('_report.rb').gsub(/app\/reports\/admin\//, '')
      end
    else
      []
    end
  end
end