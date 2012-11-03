class PaymentParticular < Particular

  def transactions
    ptt = particular_type_transaction
    act = account_transaction
    if act.account == ptt.account and act.amount + ptt.amount == 0
      nil
    else
      [ particular_type_transaction, account_transaction ]
    end
  end

private

  def particular_type_transaction
    Transaction.new( 
      { doc: doc, account: particular_type.account || current_account, transaction_date: doc.doc_date, 
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
      { amount: -total.abs }
    else
      { amount: total.abs }
    end
  end

end