class HouseFeedTypesController < ApplicationController

  def index
    @reports = House.find_by_sql(query)
    render :index, format: :pdf
  end

private

  def query
    <<-SQL
      select string_agg(distinct house_no, ', ') as houses, feed_type
        from (select house_no, min((extract(day from now() - fl.dob)/7) :: integer) as age,
                     case when min((extract(day from now() - fl.dob)/7) :: integer) >= 0 and min((extract(day from now() - fl.dob)/7) :: integer) <=  4 then 'A1'
	                        when min((extract(day from now() - fl.dob)/7) :: integer) >  4 and min((extract(day from now() - fl.dob)/7) :: integer) <= 10 then 'A2'
                          when min((extract(day from now() - fl.dob)/7) :: integer) > 10 and min((extract(day from now() - fl.dob)/7) :: integer) <= 15 then 'A3'
                          when min((extract(day from now() - fl.dob)/7) :: integer) > 15 and min((extract(day from now() - fl.dob)/7) :: integer) <= 16 then 'A3U'
                          when min((extract(day from now() - fl.dob)/7) :: integer) > 16 and min((extract(day from now() - fl.dob)/7) :: integer) <= 19 then 'A4'
                          when min((extract(day from now() - fl.dob)/7) :: integer) > 20 and min((extract(day from now() - fl.dob)/7) :: integer) <= 45 then 'A5'
                          when min((extract(day from now() - fl.dob)/7) :: integer) > 45 and min((extract(day from now() - fl.dob)/7) :: integer) <= 70 then 'A6'
                          else 'A7' end as feed_type
                from flocks fl
                left outer join movements mv on fl.id = mv.flock_id
                left outer join houses ho on mv.house_id = ho.id
               where extract(day from now() - fl.dob)/7 < 100
               group by house_no) as st1
      group by feed_type
    SQL
  end

end
