class PaySlipsController < ApplicationController
  before_filter :warn_doc_date, only: [:create, :update]

  def new
    @pay_slip = PaySlipGenerationService.new(params[:employee_name], params[:pay_date]).generate_pay_slip
  end
  
  def edit
    @pay_slip = PaySlip.find(params[:id])
  end

  def show
    @pay_slip = PaySlip.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @pay_slip = PaySlip.new(params[:pay_slip])
    if params[:submit] == 'Calculate'
      calculate_pay
    else
      save_slip
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

private

  def calculate_pay
    SalaryCalculationService.calculate @pay_slip
    render :calculated
  end

  def save_slip
    if @pay_slip.save
      flash[:success] = "Pay Slip '##{@pay_slip.id}' created successfully."
      redirect_to edit_pay_slip_path(@pay_slip)
    else
      flash.now[:error] = "Failed to create Pay Slip."
      render :new
    end
  end
  
end