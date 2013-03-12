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
        from cash_sales doc, cash_sale_details docd, products pd, accounts ac #{doc_tags?}
       where doc.id = docd.cash_sale_id
         and pd.id = docd.product_id
         and ac.id = doc.customer_id
         and ac.name1 ilike :customer
         and doc.doc_date >= :start_date
         and doc.doc_date <= :end_date
         #{cash_document_tag_conditions}
         #{doc_tag_condition}
    SQL
  end

  def invoice_sql
    <<-SQL
      select doc.id, doc.doc_date, ac.name1 as customer, pd.name1 as product, quantity,
             pd.unit, unit_price, quantity * unit_price as amount
        from invoices doc, invoice_details docd, products pd, accounts ac #{doc_tags?}
       where doc.id = docd.invoice_id
         and pd.id = docd.product_id
         and ac.id = doc.customer_id
         and ac.name1 ilike :customer
         and doc.doc_date >= :start_date
         and doc.doc_date <= :end_date
         #{invoice_document_tag_conditions}
         #{doc_tag_condition}
    SQL
  end

  def param_fields form
    form.input_field(:doc_tags, class: 'span4', placeholder: 'document tags...', data: { tags: sales_doc_tags }) +
    form.input_field(:customer, class: 'span5', placeholder: 'customer...') +
    form.input_field(:start_date, class: 'datepicker span3', placeholder: 'start date...') +
    form.input_field(:end_date, class: 'datepicker span3', placeholder: 'end date...')
  end

  def cash_document_tag_conditions
    if !doc_tags.blank?
      <<-SQL
        AND doc.id = doctgs.taggable_id 
        AND doctg.id = doctgs.tag_id 
        AND doctgs.taggable_type = 'CashSale'
      SQL
    else
      ''
    end
  end

  def invoice_document_tag_conditions
    if !doc_tags.blank?
      <<-SQL
        AND doc.id = doctgs.taggable_id
        AND doctg.id = doctgs.tag_id
        AND doctgs.taggable_type = 'Invoice'
      SQL
    else
      ''
    end
  end

  def doc_tags?
    if doc_tags.blank?
      ''
    else
      ", tags doctg, taggings doctgs"
    end
  end

  def doc_tag_condition
    if !doc_tags.blank?
      " AND lower(doctg.name) IN :splited_doc_tags "
    else
      ''
    end
  end

  def doc_tags
    @options[:doc_tags]
  end

  def splited_doc_tags
    doc_tags ? '%$#,'.concat(doc_tags).split(',').map { |t| t.downcase } : [ '%$#' ]
  end

  def start_date
    @options[:start_date] ? @options[:start_date].to_date : nil
  end

  def customer
    @options[:customer]
  end

  def end_date
    @options[:end_date] ? @options[:end_date].to_date : nil
  end

  def format_amount value
    formatter.number_with_precision(value, precision: 2, delimiter: ',')
  end

  def format_date value
    value.to_date
  end
  
end