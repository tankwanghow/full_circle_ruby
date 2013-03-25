class HarvestingReport < Dossier::Report
  include SharedHelpers

  def sql
    <<-SQL
      select harvest_date, house_no, dob, (current_date - dob)/7 as age, 
             harvest_1 + harvest_2 as production, death, 
            (harvest_1 + harvest_2) * 30.0 /(
              (select sum(quantity) 
                 from movements m 
                where m.house_id = h.id
                  and m.flock_id = f.id
                 and m.move_date = (select max(move_date) from movements where m.house_id = h.id and m.flock_id = f.id)) - 
              (select sum(death) from harvesting_slips ths, harvesting_slip_details thsd where thsd.house_id = h.id
                  and thsd.flock_id = f.id
                  and thsd.harvesting_slip_id = ths.id
                  and ths.harvest_date <= :report_date)) as yield
        from flocks f, houses h, harvesting_slips hs, harvesting_slip_details hsd
       where hsd.house_id = h.id
         and hsd.flock_id = f.id
         and hsd.harvesting_slip_id = hs.id
         and hs.harvest_date = :report_date
         and h.id IN (select distinct house_id from eggs_harvesting_wages)
       order by 2
    SQL
  end

  def param_fields form
    form.input_field(:report_date, class: 'datepicker span3', placeholder: 'report date...') 
  end

  def report_date
    @options[:report_date] ? @options[:report_date].to_date : Date.today
  end
  
end