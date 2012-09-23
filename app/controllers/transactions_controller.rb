class TransactionsController < ApplicationController
  def index
    store_param :transactions_query
    session[:transactions_query][:start_date] ||= Date.current - 30
    session[:transactions_query][:end_date] ||= Date.current
    account = Account.find_by_name1(session[:transactions_query][:name])
    if account
      @transactions = account.statement(session[:transactions_query][:start_date], session[:transactions_query][:end_date])
    else
      @transactions = []
    end
  end
end
