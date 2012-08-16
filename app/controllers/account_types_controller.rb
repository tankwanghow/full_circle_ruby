class AccountTypesController < ApplicationController
  layout proc { |controller| !request.xhr? ? "application" : nil }

  def edit
    @account_type = AccountType.find(params[:id])
  end

  def update
    @account_type = AccountType.find(params[:id])
    if @account_type.update_attributes(params[:account_type])
      flash[:success] = "Account Type '#{@account_type.name}' updated successfully."
      redirect_to chart_of_accounts_path(klass: 'AccountType', id: @account_type.id)
    else
      flash[:error] = "Failed to updated Account Type."
      render :edit
    end
  end

  def new
    @account_type = AccountType.new(parent_id: params[:parent_id])
  end

  def create
    @account_type = AccountType.new(params[:account_type])
    if @account_type.save
      flash[:success] = "Account Type '#{@account_type.name}' created successfully."
      redirect_to chart_of_accounts_path(klass: 'AccountType', id: @account_type.id)
    else
      flash[:error] = "Failed to create Account Type."
      render :edit
    end
  end

  def destroy
    @account_type = AccountType.find(params[:id])
    @account_type.destroy
    flash[:success] = "Successfully deleted '#{@account_type.name}'."
    redirect_to chart_of_accounts_path(klass: 'AccountType', id: AccountType.first.id)
  end

end
