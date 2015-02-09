class CashSaleParticular < Particular

  def transactions
    [particular_type_transaction, gst_transaction].compact
  end

private

  def particular_type_transaction
    Transaction.new({ 
      doc: doc, 
      account: particular_type.account || Account.find_by_name1('General Sales'), 
      transaction_date: doc.doc_date, 
      note: doc.customer.name1 + " - " + particular_type.name,
      amount: debit_or_credit(ex_gst_total),
      user: User.current 
    })
  end

  def gst_transaction
    if gst != 0
      Transaction.new({
        doc: doc, 
        account: tax_code.gst_account, 
        transaction_date: doc.doc_date, 
        note: doc.customer.name1 + ' - GST on ' + particular_type.name,
        amount: debit_or_credit(gst),
        user: User.current  
      })
    end
  end

  def debit_or_credit(val)
    if ex_gst_total > 0
      -val.abs
    else
      val.abs
    end
  end

end