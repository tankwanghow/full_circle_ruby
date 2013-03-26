class ProductSalesReport < Dossier::Report
  include TagsHelper

  set_callback :execute, :after do
    options[:footer] = 0
    raw_results.rows.group_by{ |item| item[3] }.map do |unit, data| 
        [ unit, data.inject(0) { |sum, value| sum+= value[2].to_f } ]
      end.each do |sum|
        options[:footer] += 1
        results.rows << [nil, 'Total', formatter.number_with_precision(sum[1], precision: 2, delimiter: ','), sum[0]]
     end
  end

  def sql
    if @options[:group_by_month].to_i == 1
      monthly_sql
    else
      daily_sql
    end
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

  def tagged_product_ids_condition
    if tagged_product_ids.count > 0
      "AND pd.id IN :tagged_product_ids"
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

  def tagged_product_ids
    if product_tags.try(:downcase) != 'all'
      Product.tagged_with(product_tags).pluck('products.id')
    else
      Product.pluck(:id)
    end
  end

  def monthly_sql
    "SELECT to_char(doc_date, 'MM') || '/' || to_char(doc_date, 'YYYY') as month, name1 as product, sum(quantity) as quantity, unit" +
    "  FROM (#{ sales_sql }) Temp" +
    " GROUP BY name1, to_char(doc_date, 'MM') || '/' || to_char(doc_date, 'YYYY'), unit" +
    " ORDER BY 1, 2"
  end

  def daily_sql
    "SELECT doc_date as date, name1 as product, sum(quantity) as quantity, unit" +
    "  FROM (#{ sales_sql }) Temp" +
    " GROUP BY name1, doc_date, unit" +
    " ORDER BY 1, 2"
  end

  def sales_sql
    cash_sale_sql +
    " UNION ALL " +
    invoice_sql
  end

  def cash_sale_sql
    "SELECT DISTINCT doc.id, doc.doc_date, pd.name1, docd.quantity, pd.unit
       FROM cash_sales doc, cash_sale_details docd, products pd
      WHERE pd.id = docd.product_id
        AND doc.id = docd.cash_sale_id
        #{tagged_product_ids_condition}
        #{tagged_cash_sale_ids_condition}"
  end

  def invoice_sql
    "SELECT DISTINCT doc.id, doc.doc_date, pd.name1, docd.quantity, pd.unit
       FROM invoices doc, invoice_details docd, products pd
      WHERE pd.id = docd.product_id
        AND doc.id = docd.invoice_id
        #{tagged_product_ids_condition}
        #{tagged_invoice_ids_condition}"
  end

  def param_fields form
    form.input_field(:doc_tags, class: 'span6', placeholder: 'document tags...', data: { tags: sales_doc_tags }) +
    form.input_field(:product_tags, class: 'span6', placeholder: 'product tags...', data: { tags: Product.category_counts.map {|t| t.name } }) +
    form.input_field(:start_date, class: 'datepicker span3', placeholder: 'start date...') +
    form.input_field(:end_date, class: 'datepicker span3', placeholder: 'end date...') +
    form.label('Group by Month', class: 'checkbox') +
    form.input_field(:group_by_month, as: :boolean) 
  end

  def doc_tags
    @options[:doc_tags]
  end

  def product_tags
    @options[:product_tags]
  end

  def group_by_month
    @options[:group_by_month]
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

end