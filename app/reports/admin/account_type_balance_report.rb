class AccountTypeBalanceReport < AdminReportBase
  include SharedHelpers

  def sql
    bf_balance_type_sql +
    " UNION ALL " +
    non_bf_balance_type_sql +
    " ORDER BY 1, 2"
  end

  def bf_balance_type_sql
    <<-SQL
      SELECT acty.name as type, sum(txn.amount) as balance
        FROM accounts ac, transactions txn, account_types acty
       WHERE ac.id = txn.account_id 
         AND ac.account_type_id = acty.id
         AND txn.transaction_date <= :end_date
         AND acty.bf_balance = true
       GROUP BY acty.name
    SQL
  end

  def non_bf_balance_type_sql
    <<-SQL
      SELECT acty.name as type, sum(txn.amount) as balance
        FROM accounts ac, transactions txn, account_types acty
       WHERE ac.id = txn.account_id 
         AND ac.account_type_id = acty.id
         AND txn.transaction_date >= :start_date
         AND txn.transaction_date <= :end_date
         AND acty.bf_balance = false
       GROUP BY acty.name
    SQL
  end

  def param_fields form
    form.input_field :end_date, class: 'datepicker span5', placeholder: 'end date...'
  end

  def start_date
    prev_close_date(end_date) + 1 if end_date
  end

  def end_date
    @options[:end_date] ? @options[:end_date].to_date : nil
  end
  
end