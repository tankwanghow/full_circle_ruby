require './app/views/payments/payment_pdf'
PaymentPdf.new(@payments, self, @static_content)