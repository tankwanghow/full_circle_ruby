class ProductSalesReport < Dossier::Report
  set_callback :execute, :after do
    options[:footer] = 0
    unit_sums = {}
    raw_results.rows.each do |t|
      if unit_sums[t[3]]
        unit_sums[t[3]] += t[2].to_f
      else
        options[:footer] += 1
        unit_sums[t[3]] = t[2].to_f
      end
    end
    unit_sums.each do |k, v|
      results.rows << [nil, 'Total', formatter.number_with_precision(v, precision: 2, delimiter: ','), k]  
    end
  end

  def sql
    if @options[:group_by_month].to_i == 1
      monthly_sql
    else
      daily_sql
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
    product_tag_condition + 
    doc_tag_condition +
    " UNION ALL " +
    invoice_sql + 
    product_tag_condition + 
    doc_tag_condition
  end

  def cash_sale_sql
    <<-SQL
      SELECT DISTINCT doc.id, doc.doc_date, pd.name1, docd.quantity, pd.unit
        FROM cash_sales doc, cash_sale_details docd, products pd, 
             tags doctg, taggings doctgs, taggings pdtgs, tags pdtg
       WHERE doc.id = docd.cash_sale_id 
         AND doc.id = doctgs.taggable_id 
         AND doctg.id = doctgs.tag_id 
         AND doctgs.taggable_type = 'CashSale'
         AND pd.id = docd.product_id 
         AND pd.id = pdtgs.taggable_id 
         AND pdtgs.tag_id = pdtg.id 
         AND pdtgs.taggable_type = 'Product' 
         AND doc_date >= :start_date
         AND doc_date <= :end_date
    SQL
  end

  def invoice_sql
    <<-SQL
      SELECT DISTINCT doc.id, doc.doc_date, pd.name1, docd.quantity, pd.unit
        FROM invoices doc, invoice_details docd, products pd,
             tags doctg, taggings doctgs, taggings pdtgs, tags pdtg
       WHERE doc.id = docd.invoice_id
         AND doc.id = doctgs.taggable_id
         AND doctg.id = doctgs.tag_id
         AND doctgs.taggable_type = 'Invoice'
         AND pd.id = docd.product_id
         AND pd.id = pdtgs.taggable_id
         AND pdtgs.tag_id = pdtg.id
         AND pdtgs.taggable_type = 'Product'
         AND doc_date >= :start_date
         AND doc_date <= :end_date
    SQL
  end

  def doc_tag_condition
    if !doc_tags.blank?
      " AND lower(doctg.name) IN :splited_doc_tags "
    else
      ''
    end
  end

  def product_tag_condition
    if !product_tags.blank?
      " AND lower(pdtg.name) IN :splited_product_tags "
    else
      ''
    end
  end

  def doc_tags
    @options[:doc_tags]
  end

  def product_tags
    @options[:product_tags]
  end

  def splited_doc_tags
    doc_tags ? '%$#,'.concat(doc_tags).split(',').map { |t| t.downcase } : [ '%$#' ]
  end

  def splited_product_tags
    product_tags ? '%$#,'.concat(product_tags).split(',').map { |t| t.downcase } : [ '%$#' ]
  end

  def group_by_month
    @options[:group_by_month]
  end

  def start_date
    @options[:start_date] ? @options[:start_date].to_date : nil
  end

  def end_date
    @options[:end_date] ? @options[:end_date].to_date : nil
  end

  def format_quantity value
    formatter.number_with_precision(value, precision: 2, delimiter: ',')
  end

  def format_date value
    value.to_date
  end

end