class FixedAssetTransactionsReport < AdminReportBase
  
  def sql
    <<-SQL
      SELECT txn.transaction_date, ac.name1, txn.note, amount
        FROM fixed_assets fa 
       INNER JOIN accounts ac ON ac.id = fa.account_id
       INNER JOIN transactions txn ON ac.id = txn.account_id
       WHERE EXTRACT(YEAR FROM txn.transaction_date) = :year
       ORDER BY 2, 1
    SQL
  end
  
  def year
    @options[:year] ? @options[:year].to_i : nil
  end

  def param_fields form
    form.input_field(:year, class: 'numeric span3', placeholder: 'year...')
  end
  
end




  