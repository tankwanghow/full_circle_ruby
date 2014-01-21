class ReceiptsController < ApplicationController
  before_filter :warn_doc_date, only: [:create, :update]
  
  def edit
    @receipt = Receipt.find(params[:id])
  end

  def new
    @receipt = Receipt.new(doc_date: Date.today)
  end

  def show
    @receipt = Receipt.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @receipt = Receipt.new(params[:receipt])
    if @receipt.save
      flash[:success] = "Receipt '##{@receipt.id}' created successfully."
      redirect_to edit_receipt_path(@receipt)
    else
      flash.now[:error] = "Failed to create Receipt."
      render :new
    end
  end

  def update
    @receipt = Receipt.find(params[:id])
    if @receipt.update_attributes(params[:receipt])
      flash[:success] = "Receipt '##{@receipt.id}' updated successfully."
      redirect_to edit_receipt_path(@receipt)
    else
      flash.now[:error] = "Failed to update Receipt."
      render :edit
    end
  end

  def new_or_edit
    if Receipt.first
      redirect_to edit_receipt_path(Receipt.last)
    else
      redirect_to new_receipt_path
    end
  end
end
