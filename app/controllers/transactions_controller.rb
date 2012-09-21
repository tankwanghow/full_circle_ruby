class TransactionsController < ApplicationController
  def index
    session[:transactions_query_start_date] ||= Date.current - 30
    session[:transactions_query_end_date] ||= Date.current
    store_param :transactions_query 
    account = Account.find_by_name1(session[:transactions_query_name])
    if account
      @transactions = account.statement(session[:transactions_query_start_date], session[:transactions_query_end_date])
    else
      @transactions = []
    end
  end
end
