-- Transactions
select ca.name1, transactiondate, transactiontypeid, transactiontypeno, transactionterms,
       replace(replace(particulars, char(10), ' '), char(13), ' ') as particulars,
       case when debitcredit = 'D' then amount else -amount end as amount
  from actransaction act inner join chartofaccount ca on ca.accountid = act.accountid
   and year(transactiondate) >= 2011
   and year(transactiondate) <= 2012

-- PD Cheques