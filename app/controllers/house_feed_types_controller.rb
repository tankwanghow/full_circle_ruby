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
        qry_date as (select '#{qdate}'::Date as qdate),
        house_feed_list as (
          select house_no, min((qdate - fl.dob)/7 :: integer) as age,
            case when min((qdate - fl.dob) :: integer) >=  0 and min((qdate - fl.dob) :: integer) <=  35 then 'A1'
                 when min((qdate - fl.dob) :: integer) >  35 and min((qdate - fl.dob) :: integer) <=  65 then 'A2'
                 when min((qdate - fl.dob) :: integer) >  65 and min((qdate - fl.dob) :: integer) <= 125 then 'A3'
                 when min((qdate - fl.dob) :: integer) > 125 and min((qdate - fl.dob) :: integer) <= 150 then 'A4'
                 when min((qdate - fl.dob) :: integer) > 150 and min((qdate - fl.dob) :: integer) <= 320 then 'A5'
                 when min((qdate - fl.dob) :: integer) > 320 and min((qdate - fl.dob) :: integer) <= 490 then 'A6'
                 else 'A7' end as feed_type
            from qry_date, flocks fl
            left outer join movements mv on fl.id = mv.flock_id
            left outer join houses ho on mv.house_id = ho.id
           where (qdate - fl.dob)/7 < 96
           group by house_no
           order by house_no)
        select string_agg(distinct house_no, ', ') as houses, feed_type
          from house_feed_list
         group by feed_type
    SQL
  end

end
