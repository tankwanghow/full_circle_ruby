load './app/views/payments/payment_pdf.rb'
PaymentPdf.new([@payment], self, @static_content)
