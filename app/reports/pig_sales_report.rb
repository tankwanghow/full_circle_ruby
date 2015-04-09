class PigSalesReport < Dossier::Report
  include SharedHelpers

  set_callback :execute, :after do
    options[:footer] = 0
    raw_results.rows.group_by{ |item| item[4] }.map do |product, data| 
        [ product, 
          data.inject(0) { |qty, value| qty += value[6].to_f }, 
          data.inject(0) { |qty, value| qty += (value[8] == 'Kg' ? value[7].to_f : 0) },
          data.inject(0) { |qty, value| qty += value[10].to_f }]
      end.each do |sum|
        if !sum[0].blank?
          options[:footer] += 1
          total_pigs = sum[1]
          total_weight = sum[2]
          total_amount = sum[3]
          average_weight = (total_pigs > 0 ? total_weight/total_pigs : 0)
          results.rows << [nil, nil, nil, nil, 
                           'Total', sum[0], 
                           formatter.number_with_precision(total_pigs, precision: 2, delimiter: ','), 
                           formatter.number_with_precision(total_weight, precision: 2, delimiter: ','), 
                           "Avg -> #{formatter.number_with_precision(average_weight, precision: 2, delimiter: ',')}",
                           nil,
                           formatter.number_with_precision(total_amount, precision: 2, delimiter: ',')]
        end
     end
  end

  def sql
    query_definitions
  end

  def from_date
    @options[:from_date] ? @options[:from_date].to_date : Date.today
  end

  def to_date
    @options[:to_date] ? @options[:to_date].to_date : Date.today
  end  

  def param_fields form
    form.input_field(:from_date, class: 'datepicker span5', placeholder: 'from...') +
    form.input_field(:to_date, class: 'datepicker span5', placeholder: 'to...')
  end

  def query_definitions
    <<-SQL
      with 
        product_ids as (
          select pd.id, pd.name1, pd.unit
            from products pd 
           inner join taggings tgs on tgs.taggable_id = pd.id
             and tgs.taggable_type = 'Product'
           inner join tags tg on tg.id = tgs.tag_id
             and tg.name ilike 'pig'),
        sale_data as (
          select 'Invoice' as doc, pi.id, doc_date, ac.name1, product_id, package_qty, quantity, unit_price, pid.note
            from invoices pi
           inner join invoice_details pid on pi.id = pid.invoice_id
           inner join accounts ac on pi.customer_id = ac.id
           where doc_date >= :from_date
             and doc_date <= :to_date
           union all
          select 'CashSale' as doc, pi.id, doc_date, ac.name1, product_id, package_qty, quantity, unit_price, pid.note
            from cash_sales pi
           inner join cash_sale_details pid on pi.id = pid.cash_sale_id
           inner join accounts ac on pi.customer_id = ac.id
           where doc_date >= :from_date
             and doc_date <= :to_date),
        pig_sales_data as (
          select doc_date, doc, pi.id, pi.name1, pd.name1 as product, note, package_qty, quantity, pd.unit, unit_price 
            from sale_data pi 
           inner join product_ids pd on pd.id = pi.product_id),
        credit_notes as (
          select txn.doc_type, txn.doc_id, txm.doc_type as txm_type, txm.doc_id as txm_id, txm.amount
            from transactions txn inner join transaction_matchers txm 
              on txm.transaction_id = txn.id and txm.doc_type = 'CreditNote'
           where txn.doc_id in (select distinct id from pig_sales_data where doc = 'CashSale')
             and txn.doc_type = 'CashSale'
           union all
          select txn.doc_type, txn.doc_id, txm.doc_type as txm_type, txm.doc_id as txm_id, txm.amount
            from transactions txn inner join transaction_matchers txm 
              on txm.transaction_id = txn.id and txm.doc_type = 'CreditNote'
           where txn.doc_id in (select distinct id from pig_sales_data where doc = 'Invoice')
             and txn.doc_type = 'Invoice')
          
          select doc_date, doc, id, name1, product, note, 
                 package_qty as qty, quantity as weight, unit, 
                 unit_price, quantity * unit_price as amount
            from pig_sales_data psd
           union all
          select null, doc_type, doc_id, txm_type || ' ' || cast(txm_id as text), 'Discount', 
                 null, null, null, null, null, amount
            from credit_notes cn
           order by 2 , 3, 11 desc
      SQL
  end
  
end