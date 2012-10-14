module ProductsHelper
  def render_packagings_fields builder, xies_name
    product = builder.object
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'products/packaging_fields',
            headers: [['Package', 'span2'], ["Qty(#{product.unit})", 'span1'], ['Cost', 'span1']]
  end
end
