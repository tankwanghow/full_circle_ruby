class HarvestingWagesReportsController < ApplicationController

  def new
  end

  def create
    @start_date = params[:harvest_wages_report][:start_date].try(:to_date)
    @end_date = params[:harvest_wages_report][:end_date].try(:to_date)
    @reports = HarvestingSlip.find_by_sql(["
        select e.name, harvest_date, house_no, harvest_1 + harvest_2 as production, ehw.wages
          from flocks f, houses h, harvesting_slips hs, 
               harvesting_slip_details hsd, employees e,
               eggs_harvesting_wages ehw
         where hsd.house_id = h.id
           and hsd.flock_id = f.id
           and hsd.harvesting_slip_id = hs.id
           and h.id IN (select distinct house_id from eggs_harvesting_wages)
           and e.id = hs.collector_id
           and h.id = ehw.house_id  
           and hsd.harvest_1 + hsd.harvest_2 >= ehw.prod_1
           and hsd.harvest_1 + hsd.harvest_2 <= ehw.prod_2
           and hs.harvest_date >= ?
           and hs.harvest_date <= ?
         order by 1, 2, 3", @start_date, @end_date ])
    render :index, format: :pdf
  end
end