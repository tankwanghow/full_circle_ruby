with debtors_with_balance as (
  select ac.id, ac.name1, sum(amount) as balance
    from transactions txn inner join accounts ac
      on txn.account_id = ac.id inner join account_types act
      on ac.account_type_id = act.id
     and act.name ilike '%trade%debtor%'
   where extract(year from txn.transaction_date) <= 2018
   group by ac.id, ac.name1
   having sum(amount) > 0),

txn_paid_after_year_end as (
  select txn.transaction_date, txn.doc_type as txn_doc_type, txn.doc_id as txn_doc_id, ac.name1,
         txn.amount as txn_amt, string_agg(tmx.doc_type || '-' || cast(tmx.doc_id as varchar(15)), ', ') as tmx_doc,
         string_agg(cast(tmx.doc_date as varchar(11)), ', ') as tmx_date, COALESCE(sum(tmx.amount), 0) as tmx_amt
    from transactions txn
    left outer join transaction_matchers tmx
      on tmx.transaction_id = txn.id
   inner join accounts ac
      on ac.id = txn.account_id
   where txn.transaction_date <= '2018-12-31'
     and tmx.doc_date > '2018-12-31'
     and txn.doc_type = 'Invoice'
     and ac.id in (select id from debtors_with_balance)
   group by txn.transaction_date, txn.doc_type, txn.doc_id, ac.name1, txn.amount),
   
txn_unpaid_after_year_end as (
  select txn.transaction_date, txn.doc_type as txn_doc_type, txn.doc_id as txn_doc_id, ac.name1,
         txn.amount as txn_amt, string_agg(tmx.doc_type || '-' || cast(tmx.doc_id as varchar(15)), ', ') as tmx_doc,
         string_agg(cast(tmx.doc_date as varchar(11)), ', ') as tmx_date, COALESCE(sum(tmx.amount), 0) as tmx_amt
    from transactions txn
    left outer join transaction_matchers tmx
      on tmx.transaction_id = txn.id
   inner join accounts ac
      on ac.id = txn.account_id
   where txn.transaction_date <= '2018-12-31'
     and tmx.doc_date is null
     and ac.id in (select id from debtors_with_balance)
   group by txn.transaction_date, txn.doc_type, txn.doc_id, ac.name1, txn.amount),

txn_partial_paid_after_year_end as (
  select txn.transaction_date, txn.doc_type as txn_doc_type, txn.doc_id as txn_doc_id, ac.name1,
         txn.amount as txn_amt, string_agg(tmx.doc_type || '-' || cast(tmx.doc_id as varchar(15)), ', ') as tmx_doc,
         string_agg(cast(tmx.doc_date as varchar(11)), ', ') as tmx_date, COALESCE(sum(tmx.amount), 0) as tmx_amt
    from transactions txn
    left outer join transaction_matchers tmx
      on tmx.transaction_id = txn.id
   inner join accounts ac
      on ac.id = txn.account_id
   where txn.transaction_date <= '2018-12-31'
     and tmx.doc_date < '2018-12-31'
     and txn.doc_type = 'Invoice'
     and ac.id in (select id from debtors_with_balance)
   group by txn.transaction_date, txn.doc_type, txn.doc_id, ac.name1, txn.amount
  having txn.amount + COALESCE(sum(tmx.amount), 0) > 0)

select * from txn_paid_after_year_end
