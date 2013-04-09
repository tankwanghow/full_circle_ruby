load './app/views/print_harvesting_slips/harvesting_slips_pdf.rb'
HarvestingSlipsPdf.new(@slips, @at_date, self)
