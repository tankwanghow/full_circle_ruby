class DriverCommission < Dossier::Report
  include TagsHelper
  include SharedHelpers

  def sql
    sale_sql + 
    " UNION ALL " +
    pur_invoice_sql
  end

  def tagged_invoice_sql_condition
    "AND doc.id IN (#{  tagged_invoice_sql})"
  end

  def tagged_cash_sale_sql_condition
    "AND doc.id IN (#{tagged_cash_sale_sql})"
  end

  def tagged_pur_invoice_sql_condition
    "AND doc.id IN (#{tagged_pur_invoice_sql})"
  end

  def tagged_invoice_sql
    if employee_tags.try(:downcase) != 'all'
      ids = Invoice.tagged_with(employee_tags).where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('invoices.id').to_sql
    else
      ids = Invoice.where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('invoices.id').to_sql
    end
  end

  def tagged_cash_sale_sql
    if employee_tags.try(:downcase) != 'all'
      ids = CashSale.tagged_with(employee_tags).where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('cash_sales.id').to_sql
    else
      ids = CashSale.where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('cash_sales.id').to_sql
    end
  end

  def tagged_pur_invoice_sql
    if employee_tags.try(:downcase) != 'all'
      ids = PurInvoice.tagged_with(employee_tags).where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('pur_invoices.id').to_sql
    else
      ids = PurInvoice.where('doc_date >= ?', start_date).where('doc_date <= ?', end_date).select('pur_invoices.id').to_sql
    end
  end

  def string_agg_tag_names doc_type
    "(select string_agg(DISTINCT tg.name, '|' ORDER BY tg.name)
        from tags tg, taggings tgs 
       where tg.id = tgs.tag_id 
         and taggable_type = '#{doc_type}'
         and tgs.context = 'tags'
         and tgs.taggable_id = doc.id) as tags"
  end

  def string_agg_loader_tag_names doc_type
    "(select string_agg(DISTINCT tg.name, '|' ORDER BY tg.name)
        from tags tg, taggings tgs 
       where tg.id = tgs.tag_id 
         and taggable_type = '#{doc_type}'
         and tgs.context = 'loader'
         and tgs.taggable_id = doc.id) as loader_tags"
  end

  def string_agg_unloader_tag_names doc_type
    "(select string_agg(DISTINCT tg.name, '|' ORDER BY tg.name)
        from tags tg, taggings tgs 
       where tg.id = tgs.tag_id 
         and taggable_type = '#{doc_type}'
         and tgs.context = 'unloader'
         and tgs.taggable_id = doc.id) as unloader_tags"
  end

  def field_selects
    "doc.doc_date, count(distinct doc.id) as doc,
     string_agg(distinct ac.name1, '|' order by ac.name1) as customers,
     case when lower(city) = 'kampar' then city else 'others' end as city,
     sum(docd.quantity) as qty, pd.unit, 
     string_agg(distinct pd.name1, '|' order by pd.name1) as particulars"
  end

  def group_bys
    "group by doc.doc_date, pd.unit, tags, loader_tags, unloader_tags, city"
  end

  def sale_sql
    <<-SQL
      select doc_date, sum(doc) as doc, 
             string_agg(customers, '|') as customers,
             case when lower(city) = 'kampar' then city else 'others' end as city,
             sum(qty) as qty, unit,
             string_agg(particulars, ', ') as particulars,
             string_agg(distinct tags, ' ') as tags,
             string_agg(distinct loader_tags, ' ') as loader_tags,
             string_agg(distinct unloader_tags, ' ') as unloader_tags
        from (#{cash_sale_sql} union all #{invoice_sql}) as sales
       group by doc_date, unit, tags, loader_tags, unloader_tags, city
    SQL
  end

  def account_city_sql
    "(select acc.id, acc.name1, ad.city
        from accounts acc 
       inner join addresses ad 
          on ad.addressable_type = 'Account' 
         and ad.addressable_id = acc.id
       group by acc.id, acc.name1, ad.city) as ac"
  end

  def cash_sale_sql
    "select #{field_selects},
            #{string_agg_tag_names('CashSale')},
            #{string_agg_loader_tag_names('CashSale')},
            #{string_agg_unloader_tag_names('CashSale')}
       from cash_sales doc, cash_sale_details docd, products pd, #{account_city_sql}
      where ac.id = doc.customer_id
        and doc.id = docd.cash_sale_id
        and pd.id = docd.product_id
        and docd.unit_price > 0
        #{tagged_cash_sale_sql_condition}
        #{group_bys}"
  end

  def invoice_sql
    "select #{field_selects},
            #{string_agg_tag_names('Invoice')},
            #{string_agg_loader_tag_names('Invoice')},
            #{string_agg_unloader_tag_names('Invoice')}
       from invoices doc, invoice_details docd, products pd, #{account_city_sql}
      where ac.id = doc.customer_id
        and doc.id = docd.invoice_id
        and pd.id = docd.product_id
        and docd.unit_price > 0
        #{tagged_invoice_sql_condition}
        #{group_bys}"
  end

  def pur_invoice_sql
    "select #{field_selects},
            #{string_agg_tag_names('PurInvoice')},
            #{string_agg_loader_tag_names('PurInvoice')},
            #{string_agg_unloader_tag_names('PurInvoice')}
       from pur_invoices doc, pur_invoice_details docd, products pd, #{account_city_sql}
      where ac.id = doc.supplier_id
        and doc.id = docd.pur_invoice_id
        and pd.id = docd.product_id
        and docd.unit_price > 0
        #{tagged_pur_invoice_sql_condition}
        #{group_bys}"
  end

  def employee_tags
    @options[:employee_tags]
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
    value.truncate 20
  end

  def format_qty value
    formatter.number_with_precision(value, precision: 2, delimiter: ',')
  end  

  def format_customers value
    customers = value.split('|').compact.uniq
    customers.map { |t| t.scan(/[A-Z]/).join }.join(', ').strip.truncate 20
  end

end