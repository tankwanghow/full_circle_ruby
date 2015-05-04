class PaySlipGenerationsController < ApplicationController
  def index
    store_param :pay_slip_generations
    session[:pay_slip_generations][:date] ||= Date.current
    
    @paid_employees = Employee.paid(session[:pay_slip_generations][:date].to_date)
    @unpaid_employees = Employee.unpaid(session[:pay_slip_generations][:date].to_date)
  end

  def new
    @pay_slips = []
    @gen_pay = PaySlipGenerationService.new params[:gen_pay]
  end

  def create
    emp = Employee.find_by_name(params[:gen_pay][:employee_name])
    pay_year = params[:gen_pay][:pay_date].to_date.year
    pay_month = params[:gen_pay][:pay_date].to_date.month
    @pay_slips = PaySlip.employee(params[:gen_pay][:employee_name]).month_year(pay_month, pay_year)
    if @pay_slips.size > 0
      render :new
    else
      redirect_to new_pay_slip_path params[:gen_pay]
    end
  end
end