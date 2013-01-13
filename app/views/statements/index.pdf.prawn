load './app/views/statements/statement_pdf.rb'
StatementPdf.new(@accounts, @start_date, @end_date, self, @static_content)
