class PaymentsController < ApplicationController

  def edit
    @payment = Payment.find(params[:id])
  end

  def new
    @payment = Payment.new(doc_date: Date.today, pay_from_name1: 'Cash in Hand')
    @payment.pay_to_particulars.build
  end

  def show
    @payment = Payment.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @payment = Payment.new(params[:payment])
    if @payment.save
      flash[:success] = "Payment '##{@payment.id}' created successfully."
      redirect_to edit_payment_path(@payment)
    else
      flash.now[:error] = "Failed to create Payment."
      render :new
    end
  end

  def update
    @payment = Payment.find(params[:id])
    if @payment.update_attributes(params[:payment])
      flash[:success] = "Payment '##{@payment.id}' updated successfully."
      redirect_to edit_payment_path(@payment)
    else
      flash.now[:error] = "Failed to update Payment."
      render :edit
    end
  end

  def new_or_edit
    if Payment.last
      redirect_to edit_payment_path(Payment.last)
    else
      redirect_to new_payment_path
    end
  end

  def typeahead_collector
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: Payment.uniq.where('collector ilike ?', term).limit(8).pluck(:collector)
  end

end

