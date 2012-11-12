module ChequesHelper
  
  def render_cheques_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'cheques/field',
            headers: [['Bank', 'span4'], ['Cheque No', 'span3'], ['City', 'span4'], ['State', 'span4'], 
                      ['Due Date', 'span4'], ['Amount', 'span3']],
            button_text: 'Add Cheque'
  end

end