class PaySlipsController < ApplicationController
  before_filter :warn_doc_date, only: [:create, :update]

  def new
    service = PaySlipGenerationService.new(params[:employee_name], params[:pay_date])
    if params[:regen]
      @pay_slip = service.regenerate_pay_slip params[:regen]
    else
      @pay_slip = service.generate_pay_slip
    end
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
    if params[:submit] == 'Calculate'
      @pay_slip.assign_attributes(params[:pay_slip])
      calculate_pay
    else
      if @pay_slip.update_attributes(params[:pay_slip])
        flash[:success] = "Pay Slip '##{@pay_slip.id}' updated successfully."
        redirect_to edit_pay_slip_path(@pay_slip)
      else
        flash.now[:error] = "Failed to update Pay Slip."
        render :edit
      end
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
