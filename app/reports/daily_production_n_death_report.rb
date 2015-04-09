class DailyProductionNDeathReport < Dossier::Report
  include SharedHelpers

  set_callback :execute, :after do
    options[:footer] = 1
    production = raw_results.rows.inject(0) { |sum, t| sum += t[1].to_f }
    death = raw_results.rows.inject(0) { |sum, t| sum += t[2].to_f }
    results.rows << ['Total', production, death]
  end

  def sql
    <<-SQL
      select hs.harvest_date, sum(harvest_1 + harvest_2) as production, sum(death) as death
        from harvesting_slips hs 
       inner join harvesting_slip_details hsd
          on hs.id = hsd.harvesting_slip_id
       where hs.harvest_date >= :from_date
         and hs.harvest_date <= :to_date
       group by harvest_date
       order by 1
    SQL
  end

  def param_fields form
    form.input_field(:from_date, class: 'datepicker span5', placeholder: 'From...') +
    form.input_field(:to_date, class: 'datepicker span5', placeholder: 'To...')
  end

  def from_date
    @options[:from_date] ? @options[:from_date].to_date : Date.today
  end

  def to_date
    @options[:to_date] ? @options[:to_date].to_date : Date.today
  end  
  
end