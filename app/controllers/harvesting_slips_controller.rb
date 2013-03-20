class HarvestingSlipsController < ApplicationController

  def edit
    @harvesting_slip = HarvestingSlip.find(params[:id])
  end

  def new
    @harvesting_slip = HarvestingSlip.new(harvest_date: Date.today)
  end

  def create
    @harvesting_slip = HarvestingSlip.new(params[:harvesting_slip])
    if @harvesting_slip.save
      flash[:success] = "HarvestingSlip '##{@harvesting_slip.id}' created successfully."
      redirect_to edit_harvesting_slip_path(@harvesting_slip)
    else
      flash.now[:error] = "Failed to create HarvestingSlip."
      render :new 
    end
  end

  def update
    @harvesting_slip = HarvestingSlip.find(params[:id])
    if @harvesting_slip.update_attributes(params[:harvesting_slip])
      flash[:success] = "HarvestingSlip '##{@harvesting_slip.id}' updated successfully."
      redirect_to edit_harvesting_slip_path(@harvesting_slip)
    else
      flash.now[:error] = "Failed to update HarvestingSlip."
      render :edit
    end
  end

  def new_or_edit
    if HarvestingSlip.first
      redirect_to edit_harvesting_slip_path(HarvestingSlip.last)
    else
      redirect_to new_harvesting_slip_path
    end
  end

end

