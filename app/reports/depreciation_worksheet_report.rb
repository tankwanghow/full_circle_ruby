class DepreciationWorksheetReport < AdminReportBase

  set_callback :execute, :after do
    options[:footer] = 1
    total = raw_results.rows.inject(0) { |sum, t| sum += t[6].to_f }
    results.rows << [nil, nil, nil, nil, nil, 'Total', formatter.number_with_precision(total, precision: 2, delimiter: ',')]  
  end
  
  def sql
    <<-SQL
      SELECT at.name as group, ac.name1 as account, to_char(aa.entry_date, 'YYYY') as addition_year, aa.amount as addition_amount, ad.entry_date as date, depreciation_rate as rate, ad.amount as depreciation
        FROM asset_depreciations ad, fixed_assets fa, accounts ac, asset_additions aa, account_types at
       WHERE ad.asset_addition_id = aa.id
         AND aa.fixed_asset_id = fa.id
         AND fa.account_id = ac.id
         AND ac.account_type_id = at.id
         AND ad.entry_date = :at_date
       ORDER BY 1, 2, 3
    SQL
  end

  def param_fields form
    form.input_field :at_date, class: 'datepicker span3', placeholder: 'date...'
  end

  def at_date
    @options[:at_date] ? @options[:at_date].to_date : nil
  end
  
end