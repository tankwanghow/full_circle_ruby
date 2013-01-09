class PrintingInBatchesController < ApplicationController

  def new
    params[:printing_in_batches] = {}
    params[:printing_in_batches][:doc_type] = ''
    params[:printing_in_batches][:start_date] = Date.today
    params[:printing_in_batches][:end_date] = Date.today
  end
  
  def create
    type = params[:printing_in_batches][:doc_type]
    start_date = params[:printing_in_batches][:start_date]
    end_date = params[:printing_in_batches][:end_date]
    @documents = []
    @documents = Document.type_is(type).date_between(start_date, end_date) if !type.blank?
  end
  
end