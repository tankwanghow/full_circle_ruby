class AccountsController < ApplicationController

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:success] = "Account '#{@account.name1}' updated successfully."
      redirect_to edit_account_path(@account) + "##{edit_account_path(@account)}"
    else
      flash[:error] = "Failed to updated Account."
      render :edit
    end
  end

  def new
    if params[:account_type_id]
      @account = Account.new(account_type_id: params[:account_type_id])
    else
      @account = Account.new
    end
  end

  def create
    @account = Account.new(params[:account])
    if @account.save
      flash[:success] = "Account '#{@account.name1}' created successfully."
      redirect_to edit_account_path(@account) + "##{edit_account_path(@account)}"
    else
      flash[:error] = "Failed to create Account."
      render :edit
    end
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    flash[:success] = "Successfully deleted '#{@account.name1}'."
    redirect_to edit_account_type_path(@account.account_type) + "##{edit_account_type_path(@account.account_type)}"
  end

end
