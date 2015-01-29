class CreditNoteParticular < Particular

  validates_numericality_of :quantity, :unit_price, greater_than: 0

   def transactions
    [particular_type_transaction, gst_transaction]
  end

private

  def particular_type_transaction
    Transaction.new({ 
      doc: doc, 
      account: particular_type.account, 
      transaction_date: doc.doc_date, 
      note: doc.account.name1 + ' ' + note,
      user: User.current,
      amount: ex_gst_total
    })
  end

  def gst_transaction
    if gst != 0
      Transaction.new({
        doc: doc, 
        account: tax_code.gst_account, 
        transaction_date: doc.doc_date, 
        note: doc.account.name1 + ' - GST on ' + particular_type.name,
        amount: gst,
        user: User.current  
      })
    end
  end

end