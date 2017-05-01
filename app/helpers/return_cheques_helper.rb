module ReturnChequesHelper

  def stuff_cheque_id_error_to_chq_no obj
    if obj.errors.messages.has_key? :cheque_id
      obj.errors.messages.merge!( chq_no: obj.errors.messages[:cheque_id] )
    end
  end

  def render_return_cheque_matchers object
    render_matchers object, object.amount
  end

end
