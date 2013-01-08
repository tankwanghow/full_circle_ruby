load './app/views/pay_slips/pay_slip_pdf.rb'
PaySlipPdf.new([@pay_slip], self, @static_content)
