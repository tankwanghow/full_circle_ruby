module ReportsHelper
  def all_report_filenames
    Dir.glob('app/reports/*_report.rb').map do |t|
      t.chomp('_report.rb').gsub(/app\/reports\//, '')
    end
  end
end