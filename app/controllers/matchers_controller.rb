class MatchersController < ApplicationController
  
  def index
    @balance = Account.find_by_name1(params[:name1]).balance_before(params[:from])
    @matchers = Transaction.with_matched_amount_and_balance(params[:name1], params[:doc_type], params[:doc_id], params[:from], params[:to])
    render partial: 'matchers/query_field' #, collection: @matchers
  end
  
end