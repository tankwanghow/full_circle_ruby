class AccountAging

  def initialize account, at_date=Date.today, aging_interval_days=15, intervals=5
    @ac = account; @at_date = at_date.to_date; @aid = aging_interval_days; @intv = intervals;
    if account.balance_at(@at_date) >= 0
      @debtor = true
      @gt_lt = '>='
    else
      @debtor = false
      @gt_lt = '<='
    end
  end

  def aging_list
    hash = {}
    @ac.class.find_by_sql(aging_list_sql).reverse_each { |t| hash[t.intv] = t.amt.to_f }
    aging(hash)
  end

  def aging hash
    temp = {}
    h = {}
    payment = hash.delete('payments')
    hash.each do |k, v|
      if check?(payment, v)
        temp[k] = 0.0
        payment = payment + v
      else
        temp[k] = v + payment
        payment = 0.0
      end
    end
    temp
    temp.reverse_each { |k, v| h[k] = v }
    h
  end

  def check? payment, value
    if @debtor
      payment + value < 0
    else
      payment + value > 0
    end
  end
  
  def aging_list_sql
    sql = transactions_with_balance_sql
    (0..(@intv - 1)).each do |t|
      sql = sql + interval_sql(t) + ' union '
    end
    sql = sql + interval_end_sql + ' union ' + full_interval_oppsite_amount_sql
  end

  def interval_sql interval
    <<-SQL
      select #{interval}, '#{interval_string(interval)}' as intv, sum(amount) as amt
        from transactions_with_balance
       where transaction_date > '#{interval_start_date(interval).to_s(:db)}'
         and transaction_date <= '#{interval_end_date(interval).to_s(:db)}'
         and amount #{@gt_lt} 0
    SQL
  end

  def interval_end_sql
    <<-SQL
      select #{@intv}, '#{@intv * @aid} days+' as intv, sum(amount) as amt
        from transactions_with_balance
       where transaction_date <= '#{interval_end_date(@intv).to_s(:db)}'
    SQL
  end

  def full_interval_oppsite_amount_sql
    if @gt_lt == '>='
      gt_lt = '<='
    else
      gt_lt = '>='
    end

    <<-SQL
      select 999, 'payments' as intv, sum(amount) as amt
        from transactions_with_balance
       where transaction_date <= '#{@at_date.to_s(:db)}'
         and transaction_date > '#{interval_end_date(@intv).to_s(:db)}'
         and amount #{gt_lt} 0
       order by 1
    SQL
  end

  def interval_start_date interval
    interval_end_date(interval) - @aid
  end

  def interval_end_date interval
    @at_date - (@aid * interval)
  end

  def interval_string interval
    "#{@aid * interval} - #{@aid * (interval + 1)} days"
  end

  def transactions_with_balance_sql
    <<-SQL
with transactions_with_balance as (
  select txn.id, txn.transaction_date, 
         txn.amount + COALESCE(sum(tmx.amount), 0) + txn.self_matched as amount
    from transactions txn left outer join  transaction_matchers tmx    
      on txn.id = tmx.transaction_id  
     and tmx.doc_date <= '#{@at_date.to_s(:db)}'
   where txn.account_id = #{@ac.id}
     and transaction_date <= '#{@at_date.to_s(:db)}'
   group by txn.id, txn.transaction_date)
    SQL
  end
  
end