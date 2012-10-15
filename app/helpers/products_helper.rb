module ProductsHelper
  def render_packagings_fields builder, xies_name
    product = builder.object
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'products/packaging_fields',
            headers: [['Package', 'span8'], ["Qty(#{product.unit})", 'span4'], ['Cost', 'span4']]
  end
end
