module ChequesHelper

  def render_cheques_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'cheques/field',
            headers: [['Bank', 'span8'], ['Cheque No', 'span6'], ['City', 'span8'], ['State', 'span8'],
                      ['Due Date', 'span8'], ['Amount', 'span6']],
            text: 'Add Cheque'
  end

  def cheque_attr_name(field, chq_id)
    "#{params[:doc_type].underscore}[cheques_attributes][" + chq_id.to_s + "][#{field.to_s}]"
  end

  def deposited? cheque
    !cheque.cr_doc_id.blank? ? ' deposited' : ''
  end

end