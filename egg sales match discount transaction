select mth, name, sum(amount) as amount
  from (
select extract(month from doc.doc_date) as mth, 'Eggs' as name, sum((quantity * unit_price) + discount) as amount
  from invoice_details docd inner join products pd 
    on pd.id = docd.product_id
   and pd.name1 ilike '%egg%grade%' inner join invoices doc 
    on doc.id = docd.invoice_id
   and extract(year from doc.doc_date) = 2017
 group by extract(month from doc.doc_date)
 union all
select extract(month from doc.doc_date) as mth, 'Discount' as name, sum(quantity * unit_price) as amount
  from particulars docd inner join particular_types pd 
    on pd.id = docd.particular_type_id
   and docd.doc_type = 'Invoice' inner join invoices doc 
    on doc.id = docd.doc_id
   and extract(year from doc.doc_date) = 2017
   and docd.doc_id IN (select distinct doc.id
                         from invoice_details docd inner join products pd 
                           on pd.id = docd.product_id
                          and pd.name1 ilike '%egg%grade%' inner join invoices doc 
                           on doc.id = docd.invoice_id
                          and extract(year from doc.doc_date) = 2017)
 group by extract(month from doc.doc_date)
 union all 
select extract(month from doc.doc_date) as mth, 'Eggs' as name, sum((quantity * unit_price) + discount) as amount
  from cash_sale_details docd inner join products pd 
    on pd.id = docd.product_id
   and pd.name1 ilike '%egg%grade%' inner join cash_sales doc 
    on doc.id = docd.cash_sale_id
   and extract(year from doc.doc_date) = 2017
 group by extract(month from doc.doc_date)
 union all
select extract(month from doc.doc_date) as mth, 'Discount' as name, sum(quantity * unit_price) as amount
  from particulars docd inner join particular_types pd 
    on pd.id = docd.particular_type_id
   and docd.doc_type = 'CashSale' inner join cash_sales doc 
    on doc.id = docd.doc_id
   and extract(year from doc.doc_date) = 2017
   and docd.doc_id IN (select distinct doc.id
                         from cash_sale_details docd inner join products pd 
                           on pd.id = docd.product_id
                          and pd.name1 ilike '%egg%grade%' inner join cash_sales doc 
                           on doc.id = docd.cash_sale_id
                          and extract(year from doc.doc_date) = 2017)
 group by extract(month from doc.doc_date)
 union all
select extract(month from doc.doc_date) as mth, 'CreditNote' as name, sum(tmx.amount) as amount
  from credit_notes doc inner join transaction_matchers tmx
    on doc.id = tmx.doc_id 
   and tmx.doc_type = 'CreditNote' inner join transactions tnx
    on tnx.id = tmx.transaction_id
   and tnx.doc_type = 'Invoice'
   and extract(year from doc.doc_date) = 2017
   and tnx.doc_id in (select distinct doc.id
                        from invoice_details docd inner join products pd 
                          on pd.id = docd.product_id
                         and pd.name1 ilike '%egg%grade%' inner join invoices doc 
                          on doc.id = docd.invoice_id
                         and extract(year from doc.doc_date) = 2017)
  group by extract(month from doc.doc_date)) my
 group by mth, name
