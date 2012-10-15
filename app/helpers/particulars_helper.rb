module ParticularsHelper
  def render_particulars_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'particulars/field',
            headers: [['Type', 'span5'], ['Note', 'span5'], ['Quantity', 'span3'], 
                      ['Unit', 'span3'], ['Price', 'span3'], ['Amount', 'span3']]
  end
end