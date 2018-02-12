class HouseFeedTypesController < ApplicationController

  def index
    @reports = House.find_by_sql(query)
    render :index, format: :pdf
  end

private

  def query date_1=Date.today.to_s(:db), date_2=Date.today.to_s(:db)
    <<-SQL
    with datelist as (
           select generate_series('#{date_1}', '#{date_2}', interval '1 day') :: date gdate),
         house_date_n_qty as (
           select gdate, h.house_no, h.id, h.capacity, h.feeding_wages, h.filling_wages,
                  (select max(flock_id) from movements mv where mv.move_date <= dl.gdate and mv.house_id = h.id) flock_id,
                  (select sum(mv.quantity) from movements mv where mv.move_date <= dl.gdate and mv.house_id = h.id)-
                  sum(death) as current_qty
             from houses h, harvesting_slips hs, harvesting_slip_details hsd, datelist dl
            where hs.id = hsd.harvesting_slip_id
              and hs.harvest_date <= dl.gdate
              and hsd.house_id = h.id
            group by gdate, h.house_no, h.id),
         house_date_flock_qty as (
           select gdate, house_no, capacity, fl.dob, round((gdate - fl.dob)::numeric(12,4)/7, 0) as age, current_qty, feeding_wages, filling_wages
             from house_date_n_qty hdq inner join flocks fl
               on fl.id = hdq.flock_id),
         house_date_feed as (
           select gdate, house_no, age, current_qty,
             case when age >= 0 and age <=  4 and current_qty > 0 then 'A1'
                  when age >  4 and age <= 10 and current_qty > 0 then 'A2'
                  when age > 10 and age <= 15 and current_qty > 0 then 'A3'
                  when age > 15 and age <= 16 and current_qty > 0 then 'A3U'
                  when age > 16 and age <= 19 and current_qty > 0 then 'A4'
                  when age > 19 and age <= 45 and current_qty > 0 then 'A5'
                  when age > 45 and age <= 70 and current_qty > 0 then 'A6'
                  when age > 70 and current_qty > 0 then 'A7'
                  else 'NO' end as feed_type, filling_wages, feeding_wages
             from house_date_flock_qty)
    select string_agg(distinct house_no, ', ') as houses, feed_type
      from house_date_feed
     where gdate = '#{date_2}'
     group by feed_type
    SQL
  end

end
