load './app/views/harvesting_reports/harvesting_report_pdf.rb'
HarvestingReportPdf.new(@reports, @report_date, self)
