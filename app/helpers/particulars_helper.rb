module ParticularsHelper
  def render_particulars_fields builder, xies_name, with_type=true
    headers = [['Type', 'span8'], ['Note', 'span10'], ['Quantity', 'span6'], 
               ['Unit', 'span4'], ['Price', 'span4'], ['Code', 'span2'], ['GST %', 'span2'], ['GST', 'span4'],
               ['Amount', 'span6']]

    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'particulars/field',
            headers: headers, with_type: with_type, text: 'Add Particular'

  end
end