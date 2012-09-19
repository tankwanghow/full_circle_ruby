class TransactionsController < ApplicationController
  def index
    params[:query] ||= {}
    params[:query][:start_date] ||= Date.current - 30
    params[:query][:end_date] ||= Date.current
    account = Account.find_by_name1(params[:query][:name])
    if account
      @transactions = account.statement(params[:query][:start_date], params[:query][:end_date])
    else
      @transactions = []
    end
  end
end
