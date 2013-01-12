class StatementsController < ApplicationController

  def show
    @start_date = params[:start_date].to_date
    @end_date = params[:end_date].to_date
    @accounts = Account.where(name1: params[:name])
    @static_content = params[:static_content]
  end

end
