load './app/views/invoices/invoice_pdf.rb'
InvoicePdf.new([@invoice], self, @static_content)
