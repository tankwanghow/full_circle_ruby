class PaySlipGenerationsController < ApplicationController
  def new
    @gen_pay = PaySlipGenerationService.new
  end

  def create
    @pay_slip = PaySlipGenerationService.new params[:gen_pay]
  end
end