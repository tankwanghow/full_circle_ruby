class DriverCommissionReport < Dossier::Report
  include TagsHelper
  include SharedHelpers

  def sql
    sale_sql + 
    " UNION ALL " +
    pur_invoice_sql
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

  def tagged_pur_invoice_ids_condition
    if tagged_pur_invoice_ids.count > 0
      "AND doc.id IN :tagged_pur_invoice_ids"
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

  def tagged_pur_invoice_ids
    if doc_tags.try(:downcase) != 'all'
      ids = PurInvoice.tagged_with(doc_tags).where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).pluck('pur_invoices.id')
    else
      ids = PurInvoice.where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).pluck('pur_invoicesinvoices.id')
    end
  end

  def string_agg_tag_names doc_type
    "(select string_agg(DISTINCT tg.name, ' ' ORDER BY tg.name)
        from tags tg, taggings tgs 
       where tg.id = tgs.tag_id 
         and taggable_type = '#{doc_type}'
         and tgs.taggable_id = doc.id) as tags"
  end

  def field_selects
    "doc.doc_date, count(distinct doc.id) as doc,
     string_agg(distinct ac.name1, '|' order by ac.name1) as customers,
     sum(docd.quantity) as qty, pd.unit, 
     string_agg(distinct pd.name1, ', ' order by pd.name1) as particulars"
  end

  def group_bys
    "group by doc.doc_date, pd.unit, tags"
  end

  def sale_sql
    <<-SQL
      select doc_date, sum(doc) as doc, 
             string_agg(customers, '|') as customers,
             sum(qty) as qty, unit,
             string_agg(particulars, ', ') as particulars,
             string_agg(distinct tags, ' ') as tags
        from (#{cash_sale_sql} union all #{invoice_sql}) as sales
       group by doc_date, unit, tags
    SQL
  end

  def cash_sale_sql
    "select #{field_selects},
            #{string_agg_tag_names('CashSale')}
       from cash_sales doc, accounts ac, cash_sale_details docd, products pd
      where ac.id = doc.customer_id
        and doc.id = docd.cash_sale_id
        and pd.id = docd.product_id
        #{tagged_cash_sale_ids_condition}
        #{group_bys}"
  end

  def invoice_sql
    "select #{field_selects},
            #{string_agg_tag_names('Invoice')}
       from invoices doc, accounts ac, invoice_details docd, products pd
      where ac.id = doc.customer_id
        and doc.id = docd.invoice_id
        and pd.id = docd.product_id
        #{tagged_invoice_ids_condition}
        #{group_bys}"
  end

  def pur_invoice_sql
    "select #{field_selects},
            #{string_agg_tag_names('PurInvoice')}
       from pur_invoices doc, accounts ac, pur_invoice_details docd, products pd
      where ac.id = doc.supplier_id
        and doc.id = docd.pur_invoice_id
        and pd.id = docd.product_id
        #{tagged_pur_invoice_ids_condition}
        #{group_bys}"
  end

  def param_fields form
    form.input_field(:doc_tags, class: 'span6', placeholder: 'document tags...', data: { tags: sales_doc_tags }) +
    form.input_field(:start_date, class: 'datepicker span3', placeholder: 'start date...') +
    form.input_field(:end_date, class: 'datepicker span3', placeholder: 'end date...')
  end

  def doc_tags
    @options[:doc_tags]
  end

  def start_date
    @options[:start_date] ? @options[:start_date].to_date : Date.today
  end

  def end_date
    @options[:end_date] ? @options[:end_date].to_date : Date.today
  end

  def format_quantity value
    formatter.number_with_precision(value, precision: 2, delimiter: ',')
  end

  def format_date value
    value.to_date
  end

  def format_particulars value
    value.truncate 50
  end

  def format_qty value
    formatter.number_with_precision(value, precision: 2, delimiter: ',')
  end  

  def format_customers value
    customers = value.split('|')
    customers.map { |t| t.scan(/[A-Z]/).join }.join(', ').strip
  end

end