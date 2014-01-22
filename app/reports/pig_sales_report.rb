class PigSalesReport < Dossier::Report
  include SharedHelpers

  set_callback :execute, :after do
    options[:footer] = 0
    raw_results.rows.group_by{ |item| item[4] }.map do |doc, data| 
        [ doc, 
          data.inject(0) { |qty, value| qty += value[6].to_f }, 
          data.inject(0) { |qty, value| qty += (value[8].upcase == 'KG' ? value[7].to_f : 0) }]
      end.each do |sum|
        options[:footer] += 1
        results.rows << [nil, nil, nil, nil, 
                         'Total', sum[0], 
                         formatter.number_with_precision(sum[1], precision: 2, delimiter: ','), 
                         formatter.number_with_precision(sum[2], precision: 2, delimiter: ','), 
                         "Avg -> #{formatter.number_with_precision(sum[2]/sum[1], precision: 2, delimiter: ',')}",
                         nil]
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
    form.input_field(:from_date, class: 'datepicker span3', placeholder: 'from...') +
    form.input_field(:to_date, class: 'datepicker span3', placeholder: 'to...')
  end

  def query_definitions
    <<-SQL
      with product_ids as (
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
           and doc_date <= :to_date)

        select doc_date, doc, pi.id, pi.name1, pd.name1 as product, note, package_qty, quantity, pd.unit, unit_price 
          from sale_data pi 
         inner join product_ids pd on pd.id = pi.product_id
         order by 1,3,4,5
      SQL
  end
  
end