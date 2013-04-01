class HarvestingSevenDaysReport < Dossier::Report
  include SharedHelpers

  def sql
    <<-SQL
      select house_no, count(*) as Days, dob, avg(age) as age, 
             avg(production) as production, avg(QtyLeft) as alive,
             avg(production)/avg(QtyLeft) as yield
        from (select house_no, dob, (harvest_date - dob)/7 as age, 
                     (harvest_1 + harvest_2) * 30 as production,
                     (select sum(quantity) from movements m 
                       where m.house_id = h.id and m.flock_id = f.id
                         and m.move_date = (select max(move_date) from movements 
                                             where m.house_id = h.id and m.flock_id = f.id)) -
                     (select sum(death) from harvesting_slips ths, harvesting_slip_details thsd 
                       where thsd.house_id = h.id
                         and thsd.flock_id = f.id
                         and thsd.harvesting_slip_id = ths.id
                         and ths.harvest_date <= hs.harvest_date) as QtyLeft
        from flocks f, houses h, harvesting_slips hs, harvesting_slip_details hsd
       where hsd.house_id = h.id
         and hsd.flock_id = f.id
         and hsd.harvesting_slip_id = hs.id
         and hs.harvest_date <= :report_date
         and hs.harvest_date > :report_date_minus_7
         and h.id IN (select distinct house_id from eggs_harvesting_wages)) as step1
       group by dob, house_no
       order by 3 desc, 1
    SQL
  end

  def param_fields form
    form.input_field(:report_date, class: 'datepicker span3', placeholder: 'Date...')
  end

  def report_date
    @options[:report_date] ? @options[:report_date].to_date : Date.today
  end

  def report_date_minus_7
    @options[:report_date] ? @options[:report_date].to_date - 7 : Date.today - 7
  end  

  def format_production val
    formatter.number_with_precision(val, :precision => 2)
  end

  def format_alive val
    formatter.number_with_precision(val, :precision => 2)
  end

  def format_age val
    formatter.number_with_precision(val, :precision => 2)
  end

  def format_yield val
    formatter.number_to_percentage (val.to_f*100), precision: 2
  end
  
end