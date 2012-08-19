class PaymentsController < SubDomainController

  def edit
    @payment = Payment.find(params[:id])
  end

  def new
    @payment = Payment.new(doc_date: Date.today)
  end

  def create
    @payment = Payment.new(params[:payment])
    if @payment.save
      flash[:success] = "Payment '##{@payment.id}' created successfully."
      redirect_to edit_payment_path(@payment)
    else
      flash[:error] = "Failed to create Payment."
      render :new
    end
  end

  def update
    @payment = Payment.find(params[:id])
    if @payment.update_attributes(params[:payment])
      flash[:success] = "Payment '##{@payment.id}' updated successfully."
      redirect_to edit_payment_path(@payment)
    else
      flash[:error] = "Failed to update Payment."
      render :edit
    end
  end

end

