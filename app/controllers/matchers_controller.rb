class MatchersController < ApplicationController
  
  def index
    @matchers = Transaction.with_matched_amount_and_balance(params[:name1], params[:doc_type], params[:doc_id], params[:from], params[:to])
    if @matchers and @matchers.count > 0
      render partial: 'matchers/query_field', collection: @matchers
    else
      render text: '<h3>No record!</h3>'
    end
  end
  
end