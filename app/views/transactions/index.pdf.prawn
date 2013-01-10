load './app/views/transactions/transactions_pdf.rb'
TransactionsPdf.new(@transactions, self, @static_content)
