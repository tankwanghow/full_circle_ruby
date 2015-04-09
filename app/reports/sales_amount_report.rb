class SalesAmountReport < Dossier::Report
  include TagsHelper

  set_callback :execute, :after do
    options[:footer] = 0
    raw_results.rows.group_by{ |item| item[0] }.map do |doc, data| 
        [ doc, data.inject(0) { |sum, value| sum+= value[5].to_f } ]
      end.each do |sum|
        options[:footer] += 1
        results.rows << [nil, nil, nil, 'Total', sum[0], formatter.number_with_precision(sum[1], precision: 2, delimiter: ',')]
     end
  end

  def sql
    cash_sql +
    "UNION ALL" +
    invoice_sql +
    "ORDER BY 4, 1, 2"
  end

  def cash_sql
    <<-SQL
      select 'CashSale' as doc, doc.id, doc.sale_no, doc.doc_date, ac.name1 as customer,
             (select sum(quantity * unit_price) from cash_sale_details where cash_sale_id = doc.id) + 
             COALESCE((select sum(quantity * unit_price) from particulars where doc_id = doc.id and doc_type = 'CashSale'), 0 ) as amount
        from cash_sales doc, accounts ac
       where ac.id = doc.customer_id
         and doc.doc_date >= :start_date
         and doc.doc_date <= :end_date
         #{tagged_cash_sale_ids_condition}
    SQL
  end

  def invoice_sql
    <<-SQL
      select 'Invoice' as doc, doc.id, '' as sale_no, doc.doc_date, ac.name1 as customer,
             (select sum(quantity * unit_price) from invoice_details where invoice_id = doc.id) + 
             COALESCE((select sum(quantity * unit_price) from particulars where doc_id = doc.id and doc_type = 'Invoice'), 0 ) as amount
        from invoices doc, accounts ac
       where ac.id = doc.customer_id
         and doc.doc_date >= :start_date
         and doc.doc_date <= :end_date
         #{tagged_invoice_ids_condition}
    SQL
  end

  def param_fields form
    form.input_field(:doc_tags, class: 'span6', placeholder: 'document tags...', data: { tags: sales_doc_tags }) +
    form.input_field(:start_date, class: 'datepicker span5', placeholder: 'start date...') +
    form.input_field(:end_date, class: 'datepicker span5', placeholder: 'end date...')
  end

  def tagged_invoice_ids_condition
    if tagged_invoice_ids.count > 0
      "AND doc.id IN :tagged_invoice_ids"
    else
      'AND 1=0'
    end
  end

  def tagged_cash_sale_ids_condition
    if tagged_cash_sale_ids.count > 0
      "AND doc.id IN :tagged_cash_sale_ids"
    else
      'AND 1=0'
    end
  end

  def tagged_invoice_ids
    if doc_tags.try(:downcase) != 'all'
      ids = Invoice.tagged_with(doc_tags).where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).pluck('invoices.id')
    else
      ids = Invoice.where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).pluck('invoices.id')
    end
  end

  def tagged_cash_sale_ids
    if doc_tags.try(:downcase) != 'all'
      ids = CashSale.tagged_with(doc_tags).where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).pluck('cash_sales.id')
    else
      ids = CashSale.where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).pluck('cash_sales.id')
    end
  end

  def doc_tags
    @options[:doc_tags].try(:downcase)
  end

  def start_date
    @options[:start_date] ? @options[:start_date].to_date : Date.today
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