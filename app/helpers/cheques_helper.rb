module ChequesHelper

  def render_cheques_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'cheques/field',
            headers: [['Bank', 'span4'], ['Cheque No', 'span3'], ['City', 'span4'], ['State', 'span4'],
                      ['Due Date', 'span4'], ['Amount', 'span3']],
            text: 'Add Cheque'
  end

  def cheque_attr_name(field, chq_id)
    "#{params[:doc_type].underscore}[cheques_attributes][" + chq_id.to_s + "][#{field.to_s}]"
  end

  def deposited? cheque
    !cheque.cr_doc_id.blank? ? ' deposited' : ''
  end

end