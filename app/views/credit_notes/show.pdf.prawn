load './app/views/credit_notes/credit_note_pdf.rb'
PaymentPdf.new([@credit_note], self, @static_content)
