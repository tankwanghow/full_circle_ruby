class SalesAmountReport < Dossier::Report
  include TagsHelper

  set_callback :execute, :after do
    options[:footer] = 1
    balance = raw_results.rows.inject(0) { |sum, t| sum += t[5].to_f }
    results.rows << [nil, nil, nil, nil, 'Total', formatter.number_with_precision(balance, precision: 2, delimiter: ',')]  
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
        from cash_sales doc, accounts ac #{doc_tags?}
       where ac.id = doc.customer_id
         and doc.doc_date >= :start_date
         and doc.doc_date <= :end_date
         #{cash_document_tag_conditions}
         #{doc_tag_condition}
    SQL
  end

  def invoice_sql
    <<-SQL
      select 'Invoice' as doc, doc.id, '' as sale_no, doc.doc_date, ac.name1 as customer,
             (select sum(quantity * unit_price) from invoice_details where invoice_id = doc.id) + 
             COALESCE((select sum(quantity * unit_price) from particulars where doc_id = doc.id and doc_type = 'Invoice'), 0 ) as amount
        from invoices doc, accounts ac #{doc_tags?}
       where ac.id = doc.customer_id
         and doc.doc_date >= :start_date
         and doc.doc_date <= :end_date
         #{invoice_document_tag_conditions}
         #{doc_tag_condition}
    SQL
  end

  def param_fields form
    form.input_field(:doc_tags, class: 'span5', placeholder: 'document tags...', data: { tags: sales_doc_tags }) +
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