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
             sum(CASE WHEN ad.entry_date < :at_date THEN ad.amount ELSE 0 END) as cume_depre,
             sum(CASE WHEN ad.entry_date = :at_date THEN ad.amount ELSE 0 END) as cur_depre,
             aa.amount -
             sum(CASE WHEN ad.entry_date < :at_date THEN ad.amount ELSE 0 END) -
             sum(CASE WHEN ad.entry_date = :at_date THEN ad.amount ELSE 0 END) as nbv
        FROM asset_depreciations ad, fixed_assets fa, 
             accounts ac, asset_additions aa, account_types aty
       WHERE ad.asset_addition_id = aa.id
         AND aa.fixed_asset_id = fa.id
         AND fa.account_id = ac.id
         AND ac.account_type_id = aty.id
         AND ad.entry_date <= :at_date
       group by type, account, addition_year, addition_amount, rate
       ORDER BY 1, 2, 3, 5
    SQL
  end

  def param_fields form
    form.input_field :at_date, class: 'datepicker span5', placeholder: 'date...'
  end

  def at_date
    @options[:at_date] ? @options[:at_date].to_date : nil
  end 
  
end