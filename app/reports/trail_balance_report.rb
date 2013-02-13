class TrailBalanceReport < Dossier::Report
  
  def sql
    <<-SQL
      SELECT ac.name1 as account, sum(txn.amount) as balance
        FROM accounts ac, transactions txn, account_types acty
       WHERE ac.id = txn.account_id 
         AND acty.account_type_id = acty.id
         AND txn.transaction_date <= :end_date
       GROUP BY ac.name1
    SQL
  end

  def bf_balance_account_sql
    <<-SQL
      SELECT ac.name1 as account, sum(txn.amount) as balance
        FROM accounts ac, transactions txn, account_types acty
       WHERE ac.id = txn.account_id 
         AND acty.account_type_id = acty.id
         AND txn.transaction_date <= :end_date
         AND acty.bf_balance = true
       GROUP BY ac.name1
    SQL
  end

  def non_bf_balance_account_sql

  end  
  
end