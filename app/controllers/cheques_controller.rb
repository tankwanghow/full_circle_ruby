class ChequesController < ApplicationController
  
  def depositable
    @cheques = Cheque.not_credited.dued(params[:due_date]).limit(params[:limit]) |
               Cheque.cr_doc_is(params[:doc_type], params[:doc_id])
    render partial: 'cheques/query_field'
  end

  def return_cheque
    return_to = Account.find_by_name1(params[:return_to]).try(:id) || 0
    @cheque = Cheque.where(db_ac_id: return_to, chq_no: params[:chq_no]).where('bank ~* ?', params[:bank]).last
    if @cheque
      cr_ac_name1 = @cheque.cr_ac ? @cheque.try(:cr_ac).try(:name1) : 'Post Dated Cheques'
      render json: @cheque.attributes.merge(return_from_name1: cr_ac_name1)
    else
      render json: nil
    end
  end
  
end