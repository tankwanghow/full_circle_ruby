class DepositsController < ApplicationController
  before_filter :warn_doc_date, only: [:create, :update]
  
  def edit
    @deposit = Deposit.find(params[:id])
  end

  def new
    @deposit = Deposit.new(doc_date: Date.today)
  end

  def show
    @deposit = Deposit.find(params[:id])
    @static_content = params[:static_content]
  end

  def create
    @deposit = Deposit.new(params[:deposit])
    if @deposit.save
      flash[:success] = "Deposit '##{@deposit.id}' created successfully."
      redirect_to edit_deposit_path(@deposit)
    else
      flash.now[:error] = "Failed to create Deposit."
      render :new
    end
  end

  def update
    @deposit = Deposit.find(params[:id])
    if @deposit.update_attributes(params[:deposit])
      flash[:success] = "Deposit '##{@deposit.id}' updated successfully."
      redirect_to edit_deposit_path(@deposit)
    else
      flash.now[:error] = "Failed to update Deposit."
      render :edit
    end
  end

  def new_or_edit
    if Deposit.first
      redirect_to edit_deposit_path(Deposit.last)
    else
      redirect_to new_deposit_path
    end
  end
end
