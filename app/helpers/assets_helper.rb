module AssetsHelper

  def render_additions_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'fixed_assets/addition_fields',
            headers: [['Year End Date', 'span8'], ['Amount', 'span8'], ['Final Amount', 'span6']], text: 'Add Addtiton'
  end

  def render_depreciations_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'fixed_assets/depreciation_fields',
            headers: [['Year End Date', 'span8'], ['Amount', 'span8']], text: 'Add Depreciation'
  end

  def render_disposals_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'fixed_assets/disposal_fields',
            headers: [['Year End Date', 'span8'], ['Amount', 'span8']], text: 'Add Disposal'
  end
end