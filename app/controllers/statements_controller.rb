class StatementsController < ApplicationController

  def new
    params[:statement] ||= {}
    params[:statement][:account_type_name] ||= ''
    @accounts = []
  end

  def create
    @start_date = (params[:start_date] || Date.today - 30).to_date
    @end_date = (params[:end_date] || Date.today).to_date
    @accounts = Account.where(id: params[:account_ids]) if params[:account_ids]
    if params[:submit] == 'Show Accounts'
      @accounts = AccountType.find_by_name(params[:statement][:account_type_name]).accounts
      render :new
    elsif params[:submit] == 'Statement'
      @static_content = true
      render :index, format: :pdf
    else
      @static_content = false
      render :index, format: :pdf
    end
  end

end
