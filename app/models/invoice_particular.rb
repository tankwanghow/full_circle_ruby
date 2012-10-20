class InvoiceParticular < Particular

  def transactions
    particular_type_transaction
  end

private

  def particular_type_transaction
    Transaction.new({ 
      doc: doc, 
      account: particular_type.account || Account.find_by_name1('General Sales'), 
      transaction_date: doc.doc_date, 
      note: particular_type.name + ' - ' + doc.customer.name1,
      user: User.current 
    }.merge(debit_or_credit_amount(total < 0)))
  end

  def debit_or_credit_amount total_flag
    if total_flag
      { debit: total.abs, credit: 0 }
    else
      { debit: 0, credit: total.abs }
    end
  end

end