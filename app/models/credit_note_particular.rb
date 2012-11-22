class CreditNoteParticular < Particular

  validates_numericality_of :quantity, :unit_price, greater_than: 0

  def transactions
    particular_type_transaction
  end

private

  def particular_type_transaction
    Transaction.new({ 
      doc: doc, 
      account: particular_type.account, 
      transaction_date: doc.doc_date, 
      note: doc.account.name1 + ' ' + note,
      user: User.current,
      amount: total
    })
  end

end