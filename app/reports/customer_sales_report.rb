class CustomerSalesReport < Dossier::Report
  include TagsHelper

  set_callback :execute, :after do
    options[:footer] = 0
    raw_results.rows.group_by{ |item| item[3] }.map do |product, data| 
        [ product, data.inject(0) { |sum, value| sum+= value[4].to_f }, data.inject(0) { |sum, value| sum+= value[7].to_f } ]
      end.each do |sum|
        options[:footer] += 1
        results.rows << [nil, nil, 'Total', sum[0], formatter.number_with_precision(sum[1], precision: 2, delimiter: ','), nil, nil ,formatter.number_with_precision(sum[2], precision: 2, delimiter: ',')]
     end
  end

  def sql
    cash_sql +
    "UNION ALL" +
    invoice_sql +
    "ORDER BY 4, 2, 1"
  end

  def cash_sql
    <<-SQL
      select doc.id, doc.doc_date, ac.name1 as customer, pd.name1 as product, quantity,
             pd.unit, unit_price, quantity * unit_price as amount
        from cash_sales doc, cash_sale_details docd, products pd, accounts ac
       where doc.id = docd.cash_sale_id
         and pd.id = docd.product_id
         and ac.id = doc.customer_id
         and ac.name1 ilike :customer
         #{tagged_cash_sale_ids_condition}
    SQL
  end

  def invoice_sql
    <<-SQL
      select doc.id, doc.doc_date, ac.name1 as customer, pd.name1 as product, quantity,
             pd.unit, unit_price, quantity * unit_price as amount
        from invoices doc, invoice_details docd, products pd, accounts ac
       where doc.id = docd.invoice_id
         and pd.id = docd.product_id
         and ac.id = doc.customer_id
         and ac.name1 ilike :customer
         #{tagged_invoice_ids_condition}
    SQL
  end

  def param_fields form
    form.input_field(:doc_tags, class: 'span6', placeholder: 'document tags...', data: { tags: sales_doc_tags }) +
    form.input_field(:customer, class: 'span10', placeholder: 'customer...') +
    form.input_field(:start_date, class: 'datepicker span4', placeholder: 'start date...') +
    form.input_field(:end_date, class: 'datepicker span4', placeholder: 'end date...')
  end

  def tagged_invoice_ids_condition
    if tagged_invoice_ids
      "AND doc.id IN (#{tagged_invoice_ids})"
    else
      'AND 1=0'
    end
  end

  def tagged_cash_sale_ids_condition
    if tagged_cash_sale_ids
      "AND doc.id IN (#{tagged_cash_sale_ids})"
    else
      'AND 1=0'
    end
  end

  def tagged_invoice_ids
    if doc_tags.try(:downcase) != 'all'
      ids = Invoice.tagged_with(doc_tags).where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('invoices.id').to_sql
    else
      ids = Invoice.where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('invoices.id').to_sql
    end
  end

  def tagged_cash_sale_ids
    if doc_tags.try(:downcase) != 'all'
      ids = CashSale.tagged_with(doc_tags).where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('cash_sales.id').to_sql
    else
      ids = CashSale.where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('cash_sales.id').to_sql
    end
  end

  def doc_tags
    @options[:doc_tags].try(:downcase)
  end

  def start_date
    @options[:start_date] ? @options[:start_date].to_date : Date.today
  end

  def customer
    @options[:customer].blank? ? '%' : @options[:customer]
  end

  def end_date
    @options[:end_date] ? @options[:end_date].to_date : Date.today
  end

  def format_amount value
    formatter.number_with_precision(value, precision: 2, delimiter: ',')
  end

  def format_date value
    value.to_date
  end
  
end