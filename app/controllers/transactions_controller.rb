class TransactionsController < ApplicationController
  before_filter :load_parent

  def index
    store_param :transactions_query
    session[:transactions_query][:start_date] ||= Date.current - 30
    session[:transactions_query][:end_date] ||= Date.current
    account = Account.find_by_name1(session[:transactions_query][:name])
    if @parent
      @transactions = @parent.transactions
    elsif account
      @transactions = account.statement(session[:transactions_query][:start_date], session[:transactions_query][:end_date])
    else
      @transactions = []
    end
  end

  private

  def load_parent
    @parent = nil
    parent_hash = params.select { |k, v| k =~ /.+_id/ }
    if !parent_hash.blank?
      parent_class = parent_hash.keys.first.gsub(/_id/, '').classify.constantize
      @parent = parent_class.find(parent_hash.values[0])
    end
  end
end
