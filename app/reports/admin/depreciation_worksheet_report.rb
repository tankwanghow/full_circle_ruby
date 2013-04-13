class DepreciationWorksheetReport < AdminReportBase

  set_callback :execute, :after do
    options[:footer] = 1
    total = raw_results.rows.inject(0) { |sum, t| sum += t[6].to_f }
    results.rows << [nil, nil, nil, nil, nil, 'Total', formatter.number_with_precision(total, precision: 2, delimiter: ','), nil]  
  end
  
  def sql
    <<-SQL
      SELECT aty.name as type, ac.name1 as account, to_char(aa.entry_date, 'YYYY') as addition_year, 
             aa.amount as addition_amount, depreciation_rate as rate, 
             sum(ad.amount) as cume_depreciation,
             (select COALESCE(sum(tt.amount), 0) from asset_depreciations tt 
               where tt.asset_addition_id = aa.id
                 and tt.entry_date = :at_date) as current_depreciation,
             aa.amount -  (sum(ad.amount) + 
             (select COALESCE(sum(tt.amount), 0)
                from asset_depreciations tt 
               where tt.asset_addition_id = aa.id
                 and tt.entry_date = :at_date)) as nbv
  FROM asset_depreciations ad, fixed_assets fa, 
       accounts ac, asset_additions aa, account_types aty
 WHERE ad.asset_addition_id = aa.id
   AND aa.fixed_asset_id = fa.id
   AND fa.account_id = ac.id
   AND ac.account_type_id = aty.id
   AND ad.entry_date <= :at_date_minus_1_year
 group by type, account, addition_year, addition_amount, rate, aa.id
 ORDER BY 1, 2, 3, 5
    SQL
  end

  def param_fields form
    form.input_field :at_date, class: 'datepicker span3', placeholder: 'date...'
  end

  def at_date
    @options[:at_date] ? @options[:at_date].to_date : nil
  end

  def at_date_minus_1_year
    at_date ? at_date - 1.year : nil
  end  
  
end