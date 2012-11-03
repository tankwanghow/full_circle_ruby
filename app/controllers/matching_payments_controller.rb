class MatchingPaymentsController < ApplicationController

  def edit
    @payment = Payment.matched.find(params[:id])
  end

  def new
    @payment = Payment.new(doc_date: Date.today, pay_from_name1: 'Cash in Hand')
  end

  def show
    @payment = Payment.matched.find(params[:id])
    @static_content = params[:static_content]
  end

  def new_or_edit
    if Payment.matched.last
      redirect_to edit_matching_payment_path(Payment.matched.last)
    else
      redirect_to new_matching_payment_path
    end
  end

end

