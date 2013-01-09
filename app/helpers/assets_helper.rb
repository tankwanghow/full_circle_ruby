module AssetsHelper
  
  def render_additions_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'fixed_assets/addition_fields',
            headers: [['Year End Date', 'span4'], ['Amount', 'span4'], ['Final Amount', 'span3']], text: 'Add Addtiton'
  end
  
  def render_depreciations_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'fixed_assets/depreciation_fields',
            headers: [['Year End Date', 'span4'], ['Amount', 'span4']], text: 'Add Depreciations'
  end

  def render_disposals_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'fixed_assets/disposal_fields',
            headers: [['Year End Date', 'span4'], ['Amount', 'span4']], text: 'Add Disposal'
  end
end