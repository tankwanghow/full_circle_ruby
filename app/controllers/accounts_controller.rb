class AccountsController < ApplicationController
  layout proc { |controller| !request.xhr? ? "application" : nil }

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:success] = "Account '#{@account.name1}' updated successfully."
      redirect_to chart_of_accounts_path(klass: 'Account', id: @account.id)
    else
      flash[:error] = "Failed to updated Account."
      render :edit
    end
  end

  def new
    @account = Account.new(account_type_id: params[:account_type_id])
  end

  def create
    @account = Account.new(params[:account])
    if @account.save
      flash[:success] = "Account '#{@account.name1}' created successfully."
      redirect_to chart_of_accounts_path(klass: 'Account', id: @account.id)
    else
      flash[:error] = "Failed to create Account."
      render :edit
    end
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    flash[:success] = "Successfully deleted '#{@account.name1}'."
    redirect_to chart_of_accounts_path(klass: 'AccountType', id: AccountType.first.id)
  end



end
