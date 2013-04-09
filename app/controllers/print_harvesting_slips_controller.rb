class PrintHarvestingSlipsController < ApplicationController
  
  def index
    @slips = []
    @slips_yesterday = []
    @at_date = Date.today
  end

  def create
    @slips = []
    @slips_yesterday = []
    @at_date = Date.today
    if params[:submit] == 'Show'
      list_html
    else
      list_pdf
    end
  end

private

  def list_html
    if params[:harvesting_slips]
      @at_date = params[:harvesting_slips][:at_date].to_date
      @slips = HarvestingSlip.harvesting_slips_for @at_date
      @slips_yesterday = HarvestingSlip.harvesting_slips_for @at_date - 1
    end
    render :index
  end

  def list_pdf
    @slips = params[:harvesting_slips]
    render :index, format: :pdf
  end
  
end