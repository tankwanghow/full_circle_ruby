class TradeDebtorsAgingReport < AdminReportBase
  include SharedHelpers

  def sql
    query_definitions
  end

  def param_fields form
    form.input_field(:interval, class: 'span3', placeholder: 'Interval...') +
    form.input_field(:report_date, class: 'datepicker span3', placeholder: 'Date...')
  end

  def report_date
    @options[:report_date] ? @options[:report_date].to_date : Date.today
  end

  def interval
    @options[:interval].to_i ? @options[:interval].to_i : 15
  end

  def report_date_int_0
    report_date - interval * 1
  end

  def report_date_int_1
    report_date - interval * 2
  end

  def report_date_int_2
    report_date - interval * 3
  end

  def report_date_int_3
    report_date - interval * 4
  end

  def report_date_int_4
    report_date - interval * 5
  end  

  def query_definitions
    <<-SQL
      with 
          trade_debtors as (
            select ac.id, ac.name1 from accounts ac
             inner join account_types act on ac.account_type_id = act.id
               and act.name = 'Trade Debtors'),
          active_trade_debtors as (
            select td.id, td.name1 from transactions txn
             inner join trade_debtors td on td.id = txn.account_id
               and txn.transaction_date <= :report_date
             group by td.id, td.name1
            having sum(txn.amount) <> 0
            union 
            select td.id, td.name1 
              from trade_debtors td
             where exists (select txn.id from transactions txn 
                            where txn.account_id = td.id
                              and txn.transaction_date <= :report_date
                  and txn.transaction_date >= :report_date_int_4)),
           transactions_with_balance as (
             select txn.id, td.id as ac_id, txn.transaction_date, 
                    txn.amount + COALESCE(sum(tmx.amount), 0) + txn.self_matched as amount
               from transactions txn 
              inner join active_trade_debtors td on td.id = txn.account_id
               left outer join  transaction_matchers tmx
                 on txn.id = tmx.transaction_id  
                and tmx.doc_date <= :report_date
              where transaction_date <= :report_date
              group by txn.id, txn.transaction_date, td.id),
           aging_lists as (
             select td.id, td.name1,
                    (select COALESCE(sum(twb.amount), 0)
                       from transactions_with_balance twb 
                      where twb.transaction_date <= :report_date
                        and twb.transaction_date > :report_date_int_0
                        and twb.ac_id = td.id
                        and amount > 0) as int0,
                    (select COALESCE(sum(twb.amount), 0)
                       from transactions_with_balance twb 
                      where twb.transaction_date <= :report_date_int_0
                        and twb.transaction_date > :report_date_int_1
                        and twb.ac_id = td.id
                        and amount > 0) as int1,
                    (select COALESCE(sum(twb.amount), 0)
                       from transactions_with_balance twb 
                      where twb.transaction_date <= :report_date_int_1
                        and twb.transaction_date > :report_date_int_2
                        and twb.ac_id = td.id
                        and amount > 0) as int2,
                    (select COALESCE(sum(twb.amount), 0)
                       from transactions_with_balance twb 
                      where twb.transaction_date <= :report_date_int_2
                        and twb.transaction_date > :report_date_int_3
                        and twb.ac_id = td.id
                        and amount > 0) as int3,
                    (select COALESCE(sum(twb.amount), 0)
                       from transactions_with_balance twb 
                      where twb.transaction_date <= :report_date_int_3
                        and twb.transaction_date > :report_date_int_4
                        and twb.ac_id = td.id
                        and amount > 0) as int4,
                    (select COALESCE(sum(twb.amount), 0)
                       from transactions_with_balance twb 
                      where twb.transaction_date <= :report_date_int_4
                        and twb.ac_id = td.id
                        and amount > 0) +
                    (select COALESCE(sum(twb.amount), 0)
                       from transactions_with_balance twb 
                      where twb.transaction_date <= :report_date
                        and twb.ac_id = td.id
                        and amount < 0) as int5
                from active_trade_debtors td)

        select name1 as name,
               case when int5 + int4 + int3 + int2 + int1 + int0 > 0 and int5 + int4 + int3 + int2 + int1 < 0 
                    then int5 + int4 + int3 + int2 + int1 + int0 
                    else case when int5 + int4 + int3 + int2 + int1 + int0 < 0 then 0 else int0 end end as  #{'_less_' + interval.to_s + '_days'},
               case when int5 + int4 + int3 + int2 + int1 > 0 and int5 + int4 + int3 + int2 < 0 
                    then int5 + int4 + int3 + int2 + int1 
                    else case when int5 + int4 + int3 + int2 + int1 < 0 then 0 else int1 end end as #{'_' + (interval * 1).to_s + '_days'},
               case when int5 + int4 + int3 + int2 > 0 and int5 + int4 + int3 < 0 
                    then int5 + int4 + int3 + int2 
                    else case when int5 + int4 + int3 + int2 < 0 then 0 else int2 end end as #{'_' + (interval * 2).to_s + '_days'},
               case when int5 + int4 + int3 > 0 and int5 + int4 < 0 
                    then int5 + int4 + int3 
                    else case when int5 + int4 + int3 < 0 then 0 else int3 end end as #{'_' + (interval * 3).to_s + '_days'},
               case when int5 + int4 > 0 and int5 < 0 
                    then int5 + int4 
                    else case when int5 + int4 < 0 then 0 else int4 end end as #{'_' + (interval * 4).to_s + '_days'},
               case when int5 > 0 
                    then int5 else 0 end as #{'_more_' + (interval * 4).to_s + '_days'},
               (select COALESCE(sum(amount), 0) from cheques 
                 where db_ac_id = al.id
                   and (cr_doc_id is null or cr_doc_type is null)) as pd_chq
         from aging_lists al
        order by 1
      SQL
  end
  
end