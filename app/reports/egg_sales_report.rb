class EggSalesReport < Dossier::Report
  set_callback :execute, :after do
    options[:footer] = 1
    sum = 0
    raw_results.rows.each do |t|
      sum += t[1].to_f
    end
    results.rows << ['Total', formatter.number_with_precision(sum, precision: 2, delimiter: ','), 'pcs']
  end

  def sql
    <<-SQL
      SELECT doc_date as date, sum(quantity) as quantity, unit
        FROM (SELECT DISTINCT cs.id, cs.doc_date, pd.name1, csd.quantity, pd.unit
                FROM cash_sales cs, cash_sale_details csd, products pd, 
                     tags cstg, taggings cstgs, taggings pdtgs, tags pdtg
               WHERE cs.id = csd.cash_sale_id 
                 AND cs.id = cstgs.taggable_id 
                 AND cstg.id = cstgs.tag_id 
                 AND cstgs.taggable_type = 'CashSale'
                 AND pd.id = csd.product_id 
                 AND pd.id = pdtgs.taggable_id 
                 AND pdtgs.tag_id = pdtg.id 
                 AND pdtgs.taggable_type = 'Product' 
                 AND lower(cstg.name) = lower(:doc_tag)
                 AND lower(pdtg.name) = lower('Eggs')
                 AND doc_date >= :start_date
                 AND doc_date <= :end_date
               UNION ALL
              SELECT DISTINCT iv.id, iv.doc_date, pd.name1, ivd.quantity, pd.unit
                FROM invoices iv, invoice_details ivd, products pd, 
                     tags ivtg, taggings ivtgs, taggings pdtgs, tags pdtg
               WHERE iv.id = ivd.invoice_id 
                 AND iv.id = ivtgs.taggable_id 
                 AND ivtg.id = ivtgs.tag_id 
                 AND ivtgs.taggable_type = 'Invoice' 
                 AND pd.id = ivd.product_id 
                 AND pd.id = pdtgs.taggable_id 
                 AND pdtgs.tag_id = pdtg.id 
                 AND pdtgs.taggable_type = 'Product' 
                 AND lower(ivtg.name) = lower(:doc_tag)
                 AND lower(pdtg.name) = lower('Eggs')
                 AND doc_date >= :start_date 
                 AND doc_date <= :end_date) Temp
       GROUP BY doc_date, unit;  
    SQL
  end

  def doc_tag
    @options[:doc_tag]
  end

  def start_date
    @options[:start_date]
  end

  def end_date
    @options[:end_date]
  end

  def format_quantity value
    formatter.number_with_precision(value, precision: 2, delimiter: ',')
  end

  def format_date value
    value.to_date
  end

end