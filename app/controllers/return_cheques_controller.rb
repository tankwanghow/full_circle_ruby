class ReturnChequesController < ApplicationController
  before_filter :warn_doc_date, only: [:create, :update]
  
  def edit
    @return_cheque = ReturnCheque.find(params[:id])
  end

  def new
    @return_cheque = ReturnCheque.new(doc_date: Date.today)
  end

  def show
    @return_cheque = ReturnCheque.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @return_cheque = ReturnCheque.new(params[:return_cheque])
    if @return_cheque.save
      flash[:success] = "ReturnCheque '##{@return_cheque.id}' created successfully."
      redirect_to edit_return_cheque_path(@return_cheque)
    else
      flash.now[:error] = "Failed to create ReturnCheque."
      render :new
    end
  end

  def update
    @return_cheque = ReturnCheque.find(params[:id])
    if @return_cheque.update_attributes(params[:return_cheque])
      flash[:success] = "ReturnCheque '##{@return_cheque.id}' updated successfully."
      redirect_to edit_return_cheque_path(@return_cheque)
    else
      flash.now[:error] = "Failed to update ReturnCheque."
      render :edit
    end
  end

  def new_or_edit
    if ReturnCheque.first
      redirect_to edit_return_cheque_path(ReturnCheque.last)
    else
      redirect_to new_return_cheque_path
    end
  end

  def typeahead_reason
    term = "%#{params[:term].scan(/(\w)/).flatten.join('%')}%"
    render json: ReturnCheque.uniq.where("reason ilike ?", term).limit(8).pluck(:reason)
  end
end
