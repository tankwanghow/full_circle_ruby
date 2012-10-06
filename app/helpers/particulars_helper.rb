module ParticularsHelper
  def render_particulars_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'particulars/field',
            headers: [['Type', 'span2'], ['Note', 'span3'], ['Quantity', 'span1'], 
                      ['Unit', 'span1'], ['Price', 'span1'], ['Amount', 'span2']]
  end
end