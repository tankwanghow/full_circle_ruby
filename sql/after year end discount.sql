with cn_matchers as (
SELECT transaction_id, cn.doc_date, txm.doc_type, cn.id as doc_id, txm.amount
  FROM transaction_matchers txm
 inner join credit_notes cn
    on cn.id = txm.doc_id
   and txm.doc_type = 'CreditNote')
 
select transaction_date, ac.name1, txn.doc_id, txn.doc_type, txn.note, txn.amount, 
       txm.doc_date as txm_date, txm.doc_type as txm_doc_type, txm.doc_id as txm_docid, txm.amount as txm_amount
  from transactions txn 
 inner join accounts ac on txn.account_id = ac.id
  left outer join cn_matchers txm on txn.id = txm.transaction_id
 where transaction_date <= '2019-12-31'
   and txn.doc_type = 'Invoice'
   and txm.doc_date > '2019-12-31'
   and account_id <> 10
   and txn.old_data = false
 order by 1, 2, 4, 3
