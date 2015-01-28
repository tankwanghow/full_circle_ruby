module ProductsHelper
  def render_packagings_fields builder, xies_name
    product = builder.object
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'products/packaging_fields',
            headers: [['Package', 'span14'], ['Qty', 'span6'], ['Cost', 'span6']], text: 'Add Packaging'
  end
end
