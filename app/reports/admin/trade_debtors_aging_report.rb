class TradeDebtorsAgingReport < AdminReportBase
  include SharedHelpers

  def sql
    query_definitions
  end

  def param_fields form
    form.input_field(:interval, class: 'span5', placeholder: 'Interval...') +
    form.input_field(:report_date, class: 'datepicker span5', placeholder: 'Date...')
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
            having sum(txn.amount) <> 0),
          transactions_balance as (
            select txn.id, txn.account_id as ac_id, txn.doc_id, txn.doc_type, txn.transaction_date,
                   txn.amount + COALESCE(sum(tmx.amount), 0) as amount
              from transactions txn
              left outer join transaction_matchers tmx
                on txn.id = tmx.transaction_id
               and tmx.doc_date <= :report_date
            inner join active_trade_debtors td on td.id = txn.account_id
             where transaction_date <= :report_date
             group by txn.id, txn.account_id, txn.transaction_date, txn.doc_id, txn.doc_type),
          transactions_with_balance as (
            select tb.id, tb.ac_id, tb.doc_id, tb.doc_type, tb.transaction_date, tb.amount - COALESCE(sum(tmx.amount), 0) as amount
              from transactions_balance tb
              left outer join transaction_matchers tmx
                on tmx.doc_id = tb.doc_id
               and tmx.doc_type = tb.doc_type
               and (select transaction_date from transactions txn where tmx.transaction_id = txn.id) <= :report_date
             group by tb.id, tb.ac_id, tb.doc_id, tb.doc_type, tb.transaction_date, tb.amount
             order by 5),
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
                    else case when int5 + int4 + int3 + int2 + int1 + int0 <= 0 then 0 else int0 end end as  #{'_less_' + interval.to_s + '_days'},

               case when int5 + int4 + int3 + int2 + int1 > 0 and int5 + int4 + int3 + int2 < 0
                    then int5 + int4 + int3 + int2 + int1
                    else case when int5 + int4 + int3 + int2 + int1 <= 0 then 0 else int1 end end as #{'_' + (interval * 1).to_s + '_days'},

               case when int5 + int4 + int3 + int2 > 0 and int5 + int4 + int3 < 0
                    then int5 + int4 + int3 + int2
                    else case when int5 + int4 + int3 + int2 <= 0 then 0 else int2 end end as #{'_' + (interval * 2).to_s + '_days'},

               case when int5 + int4 + int3 > 0 and int5 + int4 < 0
                    then int5 + int4 + int3
                    else case when int5 + int4 + int3 <= 0 then 0 else int3 end end as #{'_' + (interval * 3).to_s + '_days'},

               case when int5 + int4 > 0 and int5 < 0
                    then int5 + int4
                    else case when int5 + int4 <= 0 then 0 else int4 end end as #{'_' + (interval * 4).to_s + '_days'},

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
