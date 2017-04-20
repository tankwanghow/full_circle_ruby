class GstAccountsController < ApplicationController

  before_filter :allow_admin_only

  def index
    store_param :gst_accounts
    session[:gst_accounts][:month] ||= Date.current.prev_month.month
    session[:gst_accounts][:year] ||= Date.current.month == 1 ? Date.current.year - 1 : Date.current.year
    @date = "#{session[:gst_accounts][:year]}-#{session[:gst_accounts][:month]}-01".to_date.end_of_month
    start_date = @date.end_of_month.advance(days: -(@date.end_of_month.day - 1))
    end_date   = @date.end_of_month
    @accounts = Account.gst_accounts
    @gst_control_account = @accounts.select { |t| t.name1 =~ /Control/ }.first
    @gst_expense_account = @accounts.select { |t| t.name1 =~ /Expense/ }.first

    @summ = gst_doc_code_n_industry_code_summary start_date, end_date

    # @scn  = gst_debit_and_credit_note_sum 'credit_note', 'GST for Supply', start_date, end_date
    # @sdn  = gst_debit_and_credit_note_sum 'debit_note', 'GST for Supply', start_date, end_date
    # @cs   = gst_supply_and_acqusition_sum 'cash_sale', 'GST for Supply', start_date, end_date
    # @iv   = gst_supply_and_acqusition_sum 'invoice', 'GST for Supply', start_date, end_date
    #
    # @pcn  = gst_debit_and_credit_note_sum 'credit_note', 'GST for Purchase', start_date, end_date
    # @pdn  = gst_debit_and_credit_note_sum 'debit_note', 'GST for Purchase', start_date, end_date
    # @piv  = gst_supply_and_acqusition_sum 'pur_invoice', 'GST for Purchase', start_date, end_date
  end

  def create
    gsi = Account.find params[:gst_control_id].to_i
    aci = Account.find params[:account_id].to_i
    balance = params[:balance].to_d
    date = "#{session[:gst_accounts][:year]}-#{session[:gst_accounts][:month]}-01".to_date.end_of_month
    j = Journal.new(doc_date: date)
    if balance < 0
      aci_balance = balance.abs
      gsi_balance = -balance.abs
    else
      aci_balance = -balance.abs
      gsi_balance = balance.abs
    end
    j.transactions.build(account_id: aci.id, note: "Transfer to #{gsi.name1}", amount: aci_balance)
    j.transactions.build(account_id: gsi.id, note: "Transfer from #{aci.name1}", amount: gsi_balance)
    j.save
    redirect_to gst_accounts_path
  end

private

  def gst_doc_code_n_industry_code_summary start_date, end_date
    sql =
    <<-SQL
      select doc, code, industry_code, sum(quantity * unit_price + discount) as amount,
              sum((quantity * unit_price + discount) * gst_rate/100) as gst_amount
        from (select inv.id, doc_date, 'PurInvoice' as doc, pd.industry_code, quantity, unit_price, discount, invd.gst_rate,
             (select code from tax_codes where id = invd.tax_code_id) as code
                from pur_invoices inv inner join pur_invoice_details invd
                  on inv.id = invd.pur_invoice_id
                 and inv.doc_date >= '#{start_date.to_s(:db)}'
                 and inv.doc_date <= '#{end_date.to_s(:db)}' inner join products pd
                  on invd.product_id = pd.id
               union all
              select inv.id, doc_date, 'PurInvoice' as doc, 'others' as industry_code, quantity, unit_price, 0, invd.gst_rate,
                     (select code from tax_codes where id = invd.tax_code_id) as code
                from pur_invoices inv inner join particulars invd
                  on inv.id = invd.doc_id
                 and invd.doc_type = 'PurInvoice'
                 and inv.doc_date >= '#{start_date.to_s(:db)}'
                 and inv.doc_date <= '#{end_date.to_s(:db)}' inner join particular_types pt
                  on invd.particular_type_id = pt.id
               union all
              select inv.id, doc_date, 'Invoice' as doc, pd.industry_code, quantity, unit_price, discount, invd.gst_rate,
                     (select code from tax_codes where id = invd.tax_code_id) as code
                from invoices inv inner join invoice_details invd
                  on inv.id = invd.invoice_id
                 and inv.doc_date >= '#{start_date.to_s(:db)}'
                 and inv.doc_date <= '#{end_date.to_s(:db)}' inner join products pd
                  on invd.product_id = pd.id
               union all
              select inv.id, doc_date, 'Invoice' as doc, 'others' as industry_code, quantity, unit_price, 0, invd.gst_rate,
                     (select code from tax_codes where id = invd.tax_code_id) as code
                from invoices inv inner join particulars invd
                  on inv.id = invd.doc_id
                 and invd.doc_type = 'Invoice'
                 and inv.doc_date >= '#{start_date.to_s(:db)}'
                 and inv.doc_date <= '#{end_date.to_s(:db)}' inner join particular_types pt
                  on invd.particular_type_id = pt.id
               union all
              select inv.id, doc_date, 'CashSale' as doc, pd.industry_code, quantity, unit_price, discount, invd.gst_rate,
                     (select code from tax_codes where id = invd.tax_code_id) as code
                from cash_sales inv inner join cash_sale_details invd
                  on inv.id = invd.cash_sale_id
                 and inv.doc_date >= '#{start_date.to_s(:db)}'
                 and inv.doc_date <= '#{end_date.to_s(:db)}' inner join products pd
                  on invd.product_id = pd.id
               union all
              select inv.id, doc_date, 'CashSale' as doc, 'others' as industry_code, quantity, unit_price, 0, invd.gst_rate,
                     (select code from tax_codes where id = invd.tax_code_id) as code
                from cash_sales inv inner join particulars invd
                  on inv.id = invd.doc_id
                 and invd.doc_type = 'CashSale'
                 and inv.doc_date >= '#{start_date.to_s(:db)}'
                 and inv.doc_date <= '#{end_date.to_s(:db)}' inner join particular_types pt
                  on invd.particular_type_id = pt.id
               union all
              select inv.id, doc_date, 'CreditNote' as doc, 'others' as industry_code, quantity,
                     unit_price * case when (select tax_type from tax_codes where id = invd.tax_code_id) ilike '%purchase%' then 1 else -1 end,
                     0, invd.gst_rate,
                     (select code from tax_codes where id = invd.tax_code_id) as code
                from credit_notes inv inner join particulars invd
                  on inv.id = invd.doc_id
                 and invd.doc_type = 'CreditNote'
                 and inv.doc_date >= '#{start_date.to_s(:db)}'
                 and inv.doc_date <= '#{end_date.to_s(:db)}' inner join particular_types pt
                  on invd.particular_type_id = pt.id
               union all
              select inv.id, doc_date, 'DebitNote' as doc, 'others' as industry_code, quantity,
                     unit_price * case when (select tax_type from tax_codes where id = invd.tax_code_id) ilike '%purchase%' then -1 else 1 end,
                     0, invd.gst_rate,
                     (select code from tax_codes where id = invd.tax_code_id) as code
                from debit_notes inv inner join particulars invd
                  on inv.id = invd.doc_id
                 and invd.doc_type = 'DebitNote'
                 and inv.doc_date >= '#{start_date.to_s(:db)}'
                 and inv.doc_date <= '#{end_date.to_s(:db)}' inner join particular_types pt
                  on invd.particular_type_id = pt.id) tbl1
      group by code, doc, industry_code
      order by 2, 1, 3
      SQL
      Account.find_by_sql sql
  end




  def gst_supply_and_acqusition_sum doc, tax_type, start_date, end_date
    p = Account.find_by_sql [
      "SELECT SUM((docd.quantity * docd.unit_price) + docd.discount) as amount
         FROM #{doc}s doc
        INNER JOIN #{doc}_details docd
           ON docd.#{doc}_id = doc.id
        INNER JOIN tax_codes tx
           ON docd.tax_code_id = tx.id
          AND tx.tax_type = '#{tax_type}'
          AND tx.rate > 0
        INNER JOIN products p
           ON p.id = docd.product_id
        WHERE doc.doc_date >= ?
          AND doc.doc_date <= ?", start_date, end_date]

    k = Account.find_by_sql [
      "SELECT SUM(docd.quantity * docd.unit_price) as amount
         FROM #{doc}s doc
        INNER JOIN particulars docd
           ON docd.doc_id = doc.id
          AND docd.doc_type = '#{doc.classify}'
        INNER JOIN tax_codes tx
           ON docd.tax_code_id = tx.id
          AND tx.tax_type = '#{tax_type}'
          AND tx.rate > 0
        INNER JOIN particular_types p
           ON p.id = docd.particular_type_id
        WHERE doc.doc_date >= ?
          AND doc.doc_date <= ?", start_date, end_date]
    p[0].amount.to_f.round(2) + k[0].amount.to_f.round(2)
  end

  def gst_debit_and_credit_note_sum doc, tax_type, start_date, end_date
    k = Account.find_by_sql [
      "SELECT SUM(docd.quantity * docd.unit_price) as amount
         FROM #{doc}s doc
        INNER JOIN particulars docd
           ON docd.doc_id = doc.id
          AND docd.doc_type = '#{doc.classify}'
        INNER JOIN tax_codes tx
           ON docd.tax_code_id = tx.id
          AND tx.tax_type = '#{tax_type}'
          AND tx.rate > 0
        INNER JOIN particular_types p
           ON p.id = docd.particular_type_id
        WHERE doc.doc_date >= ?
          AND doc.doc_date <= ?", start_date, end_date]
    k[0].amount.to_f.round(2)
  end

end
