class PaySlipsController < ApplicationController
  
  def edit
    @pay_slip = PaySlip.find(params[:id])
  end

  def new
    @pay_slip = PaySlip.new(pay_date: Date.today)
  end

  def create
    @pay_slip = PaySlip.new(params[:pay_slip])
    if @pay_slip.save
      flash[:success] = "Pay Slip '##{@pay_slip.id}' created successfully."
      redirect_to edit_pay_slip_path(@pay_slip)
    else
      flash.now[:error] = "Failed to create Pay Slip."
      render :new
    end
  end

  def update
    @pay_slip = PaySlip.find(params[:id])
    if @pay_slip.update_attributes(params[:pay_slip])
      flash[:success] = "Pay Slip '##{@pay_slip.id}' updated successfully."
      redirect_to edit_pay_slip_path(@pay_slip)
    else
      flash.now[:error] = "Failed to update Pay Slip."
      render :edit
    end
  end
  
end