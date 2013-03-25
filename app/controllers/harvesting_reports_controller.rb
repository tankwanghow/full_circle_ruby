class HarvestingReportsController < ApplicationController

  def new
  end

  def create
    @report_date = params[:harvest_report][:report_date].try(:to_date)
    @reports = HarvestingSlip.find_by_sql(["
        select house_no, dob, (harvest_date - dob)/7 as age, 
               harvest_1 + harvest_2 as production, death
          from flocks f, houses h, harvesting_slips hs, 
               harvesting_slip_details hsd
         where hsd.house_id = h.id
           and hsd.flock_id = f.id
           and hsd.harvesting_slip_id = hs.id
           and hs.harvest_date = ?
           and h.id IN (select distinct house_id from eggs_harvesting_wages)
         order by 1, 2", @report_date ])
    render :index, format: :pdf
  end
end