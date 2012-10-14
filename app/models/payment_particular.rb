class PaymentParticular < Particular

  def transactions
    if particular_type.account
      [ particular_type_transaction, account_transaction ]
    else
      []
    end
  end

private

  def particular_type_transaction
    Transaction.new( 
      { doc: doc, account: particular_type.account, transaction_date: doc.doc_date, 
        note: [current_account.name1, doc.collector].join(' - '),
        user: User.current 
      }.merge(debit_or_credit_amount(total < 0))
    )
  end

  def account_transaction
    Transaction.new( 
      {
        doc: doc, account: current_account, transaction_date: doc.doc_date, 
        note: [particular_type.name, doc.collector].join(' - '),
        user: User.current 
      }.merge(debit_or_credit_amount(total > 0))
    )
  end

  def current_account
    flag == 'pay_to' ? doc.pay_to : doc.pay_from
  end

  def debit_or_credit_amount total_flag
    if total_flag
      { debit: 0, credit: total.abs }
    else
      { debit: total.abs, credit: 0 }
    end
  end

end