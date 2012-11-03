load './app/views/matching_payments/payment_pdf.rb'
PaymentPdf.new([@payment], self, @static_content)
