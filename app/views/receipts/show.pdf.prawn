load './app/views/receipts/receipt_pdf.rb'
ReceiptPdf.new([@receipt], self, @static_content)
