class HarvestingReportsController < ApplicationController
  def new
  end

  def create
    @report_date = params[:harvest_report][:report_date].try(:to_date)
    @reports = House.find_by_sql(harvesting_report_sql(@report_date))
    render :index, format: :pdf
  end

private

  def harvesting_report_sql date
    <<-SQL
    select house_no, f.dob, (harvest_date - f.dob)/7 as age,
           harvest_1 + harvest_2 as production_1, death,
           #{yield_by_date(date)}     as yield_1,
           #{yield_by_date(date-1)} as yield_2,
           #{yield_by_date(date-2)} as yield_3,
           #{yield_by_date(date-3)} as yield_4,
           #{production_by_date(date-1)} as production_2,
           #{production_by_date(date-2)} as production_3,
           #{production_by_date(date-3)} as production_4,
           name
      from flocks f, houses h, harvesting_slip_details hsd,
           harvesting_slips hs left outer join employees e on e.id = hs.collector_id
     where hsd.house_id = h.id
       and hsd.flock_id = f.id
       and hsd.harvesting_slip_id = hs.id
       and hs.harvest_date = '#{date.to_s(:db)}'
       and h.id IN (select distinct house_id from eggs_harvesting_wages)
     order by 1, 2
    SQL
  end

  def production_by_date date
    <<-SQL
       (select hsd1.harvest_1 + hsd1.harvest_2
          from harvesting_slip_details hsd1 inner join harvesting_slips hs1
            on hs1.id = hsd1.harvesting_slip_id
           and hsd1.flock_id = f.id
           and hsd1.house_id = h.id
         where hs1.harvest_date = '#{date.to_s(:db)}')
    SQL
  end

  def yield_by_date date
    <<-SQL
      (select sum(hsd1.harvest_1 + hsd1.harvest_2)*30.0
          from harvesting_slip_details hsd1 inner join harvesting_slips hs1
            on hs1.id = hsd1.harvesting_slip_id
           and hsd1.flock_id = f.id
           and hsd1.house_id = h.id
         where hs1.harvest_date = '#{date.to_s(:db)}')/
       ((select sum(mv1.quantity)
          from flocks f1 inner join movements mv1
            on mv1.flock_id = f1.id
         inner join houses h1 on h1.id = mv1.house_id
           and mv1.move_date <= '#{date.to_s(:db)}'
           and f1.id = f.id
           and h1.id = h.id) -
       (select sum(death)
          from harvesting_slip_details hsd1 inner join harvesting_slips hs1
            on hs1.id = hsd1.harvesting_slip_id
           and hsd1.flock_id = f.id
           and hsd1.house_id = h.id
         where hs1.harvest_date <= '#{date.to_s(:db)}'))
    SQL
  end

end
