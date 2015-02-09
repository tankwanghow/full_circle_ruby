class PaymentParticular < Particular

  def transactions
    if flag == 'pay_to'
      pay_to_gst_transaction
    else
      [pay_from_particulars_transaction, pay_from_gst_transaction].compact
    end
  end

  private

  def pay_to_gst_transaction
    if gst != 0
      Transaction.new({
        doc: doc, 
        account: tax_code.gst_account, 
        transaction_date: doc.doc_date, 
        note: [doc.pay_to.name1, '- GST on', particular_type.name, note].join(' '),
        amount: gst,
        user: User.current  
        })
    end
  end

  def pay_from_particulars_transaction
    Transaction.new({
      doc: doc, 
      account: particular_type.account || doc.pay_from, 
      transaction_date: doc.doc_date, 
      note: [doc.pay_from.name1, particular_type.name, note].join(' '),
      amount: ex_gst_total,
      user: User.current
      })
  end

  def pay_from_gst_transaction
    if gst != 0
      Transaction.new({
        doc: doc, 
        account: tax_code.gst_account, 
        transaction_date: doc.doc_date, 
        note: [doc.pay_from.name1, '- GST on', particular_type.name, note].join(' '),
        amount: gst,
        user: User.current  
        })
    end
  end

end