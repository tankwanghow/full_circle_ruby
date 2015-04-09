class FixedAssetsReport < AdminReportBase
  
  def sql
    <<-SQL
      SELECT aty.name AS type, ac.name1 as account, prevcost, currentcost, totalcost, 
             prevdis, currentdis, totaldis, rate, prevdep, currentdep, totaldep,
             COALESCE(totalcost,0) - COALESCE(totaldis,0) - COALESCE(totaldep,0) AS nbv
        FROM accounts ac 
       INNER JOIN account_types aty ON ac.account_type_id = aty.id 
       INNER JOIN #{costs} ON cost.account_id = ac.id
        LEFT OUTER JOIN #{depreciations} ON dep.account_id = ac.id
        LEFT OUTER JOIN #{disposals} ON dis.account_id = ac.id
      ORDER BY 1, 2
    SQL
  end

  def disposals
    <<-SQL
      (SELECT fa.id, fa.account_id,
              SUM(CASE WHEN adp.entry_date < :at_date THEN adp.amount ELSE 0 END) AS PrevDis, 
              SUM(CASE WHEN adp.entry_date = :at_date THEN adp.amount ELSE 0 END) AS CurrentDis, 
              SUM(CASE WHEN adp.entry_date < :at_date THEN adp.amount ELSE 0 END) + 
              SUM(CASE WHEN adp.entry_date = :at_date THEN adp.amount ELSE 0 END) AS TotalDis
         FROM fixed_assets fa, asset_disposals adp, asset_additions aa
        WHERE aa.fixed_asset_id = fa.id
          AND aa.id = adp.asset_addition_id
          AND adp.entry_date <= :at_date
        GROUP BY fa.id, fa.account_id) dis
    SQL
  end

  def depreciations
    <<-SQL
      (SELECT fa.id, fa.account_id,
              SUM(CASE WHEN adp.entry_date < :at_date THEN adp.amount ELSE 0 END) AS PrevDep, 
              SUM(CASE WHEN adp.entry_date = :at_date THEN adp.amount ELSE 0 END) AS CurrentDep, 
              SUM(CASE WHEN adp.entry_date < :at_date THEN adp.amount ELSE 0 END) + 
              SUM(CASE WHEN adp.entry_date = :at_date THEN adp.amount ELSE 0 END) AS TotalDep
         FROM fixed_assets fa, asset_depreciations adp, asset_additions aa
        WHERE aa.fixed_asset_id = fa.id
          AND aa.id = adp.asset_addition_id
          AND adp.entry_date <= :at_date
        GROUP BY fa.id, fa.account_id) dep
    SQL
  end

  def costs
    <<-SQL
      (SELECT fa.id, fa.account_id, fa.depreciation_rate AS rate,
              SUM(CASE WHEN aa.entry_date < :at_date THEN aa.amount ELSE 0 END) AS PrevCost, 
              SUM(CASE WHEN aa.entry_date = :at_date THEN aa.amount ELSE 0 END) AS CurrentCost, 
              SUM(CASE WHEN aa.entry_date < :at_date THEN aa.amount ELSE 0 END) + 
              SUM(CASE WHEN aa.entry_date = :at_date THEN aa.amount ELSE 0 END) AS TotalCost
         FROM fixed_assets fa, asset_additions aa
         WHERE aa.fixed_asset_id = fa.id
          AND aa.entry_date <= :at_date
        GROUP BY fa.id, fa.account_id, fa.depreciation_rate) cost
    SQL
  end

  def param_fields form
    form.input_field :at_date, class: 'datepicker span5', placeholder: 'date...'
  end

  def at_date
    @options[:at_date] ? @options[:at_date].to_date : nil
  end
  
end