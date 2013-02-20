class TrailBalanceReport < AdminReportBase
  include SharedHelpers

  set_callback :execute, :after do
    options[:footer] = 1
    balance = raw_results.rows.inject(0) { |sum, t| sum += t[1].to_f }
    results.rows << [nil, 'Balance', formatter.number_with_precision(balance, precision: 2, delimiter: ',')]  
  end
  
  def sql
    bf_balance_account_sql +
    " UNION ALL " +
    non_bf_balance_account_sql +
    " ORDER BY 2, 1 "
  end

  def bf_balance_account_sql
    <<-SQL
      SELECT acty.name as type, ac.name1 as account, sum(txn.amount) as balance
        FROM accounts ac, transactions txn, account_types acty
       WHERE ac.id = txn.account_id 
         AND ac.account_type_id = acty.id
         AND txn.transaction_date <= :end_date
         AND acty.bf_balance = true
       GROUP BY ac.name1, acty.name
    SQL
  end

  def non_bf_balance_account_sql
    <<-SQL
      SELECT acty.name as type, ac.name1 as account, sum(txn.amount) as balance
        FROM accounts ac, transactions txn, account_types acty
       WHERE ac.id = txn.account_id 
         AND ac.account_type_id = acty.id
         AND txn.transaction_date >= :start_date
         AND txn.transaction_date <= :end_date
         AND acty.bf_balance = false
       GROUP BY ac.name1, acty.name
    SQL
  end

  def param_fields form
    form.input_field :end_date, class: 'datepicker span3', placeholder: 'end date...'
  end

  def start_date
    prev_close_date(end_date) if end_date
  end

  def end_date
    @options[:end_date] ? @options[:end_date].to_date : nil
  end
  
end