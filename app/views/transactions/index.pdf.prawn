load './app/views/transactions/transactions_pdf.rb'
TransactionsPdf.new(@transactions, @account, self, @static_content)
