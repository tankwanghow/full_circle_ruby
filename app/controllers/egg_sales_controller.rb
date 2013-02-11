class EggSalesController < ApplicationController
  
  def index
    @report = CashSale.find_by_sql [query, params[:tag], params[:from], params[:to], params[:tag], params[:from], params[:to]]
    render json: @report
  end

private

  def query
    <<-SQL
      SELECT doc_date, sum(quantity), unit
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
                 AND lower(cstg.name) = lower(?)
                 AND lower(pdtg.name) = lower('Eggs')
                 AND doc_date >= ?
                 AND doc_date <= ?
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
                 AND lower(ivtg.name) = lower(?)
                 AND lower(pdtg.name) = lower('Eggs')
                 AND doc_date >= ?
                 AND doc_date <= ?) Temp
       GROUP BY doc_date, unit;  
    SQL
  end  

end