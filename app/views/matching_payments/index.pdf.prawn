require './app/views/matching_payments/payment_pdf'
PaymentPdf.new(@payments, self, @static_content)