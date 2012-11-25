class ChequesController < ApplicationController
  
  def index
    @cheques = Cheque.not_credited.dued(params[:due_date]).limit(params[:limit]) |
               Cheque.cr_doc_is(params[:doc_type], params[:doc_id])
    render partial: 'cheques/query_field'
  end
  
end