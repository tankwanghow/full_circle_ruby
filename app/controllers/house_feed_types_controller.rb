class HouseFeedTypesController < ApplicationController

  def new
  end

  def create
    @qdate = params[:house_feed_type][:qdate].to_date.to_s(:db)

    @reports = House.find_by_sql query(@qdate)
    render :index, format: :pdf
  end

private

  def query qdate=Date.today.to_s(:db)
    <<-SQL
      WITH
        qry_date as 
          (select '#{qdate}'::Date as gdate),
        house_date_n_qty as (
          select gdate, h.house_no, h.id, h.capacity, h.feeding_wages, h.filling_wages,
                 (select max(flock_id) from movements mv where mv.move_date <= dl.gdate and mv.house_id = h.id) flock_id,
                 (select sum(mv.quantity) from movements mv where mv.move_date <= dl.gdate and mv.house_id = h.id)- sum(death) as current_qty,
                 sum(case when hs.harvest_date >= dl.gdate and h.id = hsd.house_id then hsd.harvest_1 + hsd.harvest_2 else 0 end) as prod
            from houses h, harvesting_slips hs, harvesting_slip_details hsd, qry_date dl
           where hs.id = hsd.harvesting_slip_id
             and hs.harvest_date <= dl.gdate
             and hsd.house_id = h.id
           group by gdate, h.house_no, h.id),
        house_date_flock_qty as (
          select gdate, house_no, capacity, fl.dob, (gdate - fl.dob)::integer/7 as age, current_qty, feeding_wages, filling_wages,
                 sum(prod) OVER (PARTITION BY house_no ORDER BY gdate) AS cum_prod
            from house_date_n_qty hdq inner join flocks fl
              on fl.id = hdq.flock_id
           group by gdate, house_no, capacity, fl.dob, current_qty, feeding_wages, filling_wages, prod),
        house_date_feed as (
          select gdate, house_no, age, current_qty, filling_wages, feeding_wages, cum_prod,
                 case when age >= 0 and age <=  5 and current_qty > 0 then 'A1'
                      when age >  5 and age <= 10 and current_qty > 0 then 'A2'
                      when age > 10 and age <= 16 and current_qty > 0 then 'A3'
                      when age > 16 and cum_prod = 0 and current_qty > 0 then 'A4'
                      when (age > 16 or cum_prod > 0) and age <= 48 and current_qty > 0 then 'A5'
                      when age > 48 and age <= 70 and current_qty > 0 then 'A6'
                      when age > 70 and age <= 80 and current_qty > 0 then 'A7'
                      when age > 80 and current_qty > 0 then 'A8'
                      else 'NO' end as feed_type
            from house_date_flock_qty)

        select string_agg(distinct house_no, ', ') as houses, feed_type
          from house_date_feed
         group by feed_type
         order by feed_type
    SQL
  end

end
