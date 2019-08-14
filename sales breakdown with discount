/* Will not catch Previous Years Invoice Transaction Matchers */
with
invoice_by_tag as (
select doc.doc_date, doc.id, COALESCE(tg.name, 'others') as tags,
       sum(docd.quantity) as qty, string_agg(distinct pd.unit, ', ') as unit,
       sum((docd.quantity * docd.unit_price) + docd.discount) as amount
  from invoices doc inner join invoice_details docd
   on doc.id = docd.invoice_id inner join products pd
   on pd.id = docd.product_id LEFT OUTER JOIN taggings tgs
   ON tgs.taggable_id = pd.id
  AND tgs.taggable_type = 'Product' LEFT OUTER JOIN tags tg
   on tg.id = tgs.tag_id
 where extract(year from doc.doc_date) = 2018
 group by doc.doc_date, doc.id, tg.name
having sum((docd.quantity * docd.unit_price) + docd.discount) <> 0),

cash_sale_by_tag as (
select doc.doc_date, doc.id, COALESCE(tg.name, 'others') as tags,
       sum(docd.quantity) as qty, string_agg(distinct pd.unit, ', ') as unit,
       sum((docd.quantity * docd.unit_price) + docd.discount) as amount
  from cash_sales doc inner join cash_sale_details docd
   on doc.id = docd.cash_sale_id inner join products pd
   on pd.id = docd.product_id LEFT OUTER JOIN taggings tgs
   ON tgs.taggable_id = pd.id
  AND tgs.taggable_type = 'Product' LEFT OUTER JOIN tags tg
   on tg.id = tgs.tag_id
 where extract(year from doc.doc_date) = 2018
 group by doc.doc_date, doc.id, tg.name
having sum((docd.quantity * docd.unit_price) + docd.discount) <> 0) ,

invoice_amount_by_tag as (
select doc.doc_date, doc.id, doc.tags, doc.qty, doc.unit, doc.amount + COALESCE(sum(partd.quantity * partd.unit_price), 0) as amount
  from invoice_by_tag doc left outer join particulars partd
    on doc.id = partd.doc_id
   and partd.doc_type = 'Invoice'
 where tags not ilike '%share%'
 group by doc.doc_date, doc.id, doc.tags, doc.qty, doc.unit, doc.amount),

cash_sale_amount_by_tag as (
select doc.doc_date, doc.id, doc.tags, doc.qty, doc.unit, doc.amount + COALESCE(sum(partd.quantity * partd.unit_price), 0) as amount
  from cash_sale_by_tag doc left outer join particulars partd
    on doc.id = partd.doc_id
   and partd.doc_type = 'CashSale'
 where tags not ilike '%share%'
 group by doc.doc_date, doc.id, doc.tags, doc.qty, doc.unit, doc.amount),

credit_note_amount as (
select txn.doc_id, txn.doc_type, sum(txm.amount) as amount, txm.doc_id as cn_doc_id
  from transactions txn inner join transaction_matchers txm
    on txm.transaction_id = txn.id
   and extract(year from txn.transaction_date) = 2018 inner join credit_notes cn
    on txm.doc_type = 'CreditNote'
   and txm.doc_id = cn.id
   and extract(year from cn.doc_date) = 2018
 group by txn.doc_id, txn.doc_type, txm.doc_id),

invoice_amount_after_cn_by_tag as (
select doc.id, doc.doc_date, doc.tags, doc.qty, doc.unit, doc.amount + COALESCE(sum(cn.amount), 0) as amount
  from invoice_amount_by_tag doc left outer join credit_note_amount cn
    on cn.doc_id = doc.id
 group by doc.id, doc.doc_date, doc.tags, doc.qty, doc.unit, doc.amount)

select extract(month from doc_date), extract(year from doc_date), 'invoice', 
       doc.tags, sum(doc.amount) as amount
  from invoice_amount_after_cn_by_tag doc
  group by doc.tags, extract(month from doc_date), extract(year from doc_date)
 union all
select extract(month from doc_date), extract(year from doc_date), 'cash', 
       doc.tags, sum(doc.amount) as amount
  from cash_sale_amount_by_tag doc
  group by doc.tags, extract(month from doc_date), extract(year from doc_date)
