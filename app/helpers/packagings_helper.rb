module PackagingsHelper
  def render_products_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'packagings/product_fields',
            headers: [['Product', 'span2'], ['Quantity', 'span1'], ['Cost', 'span1']]
  end
end
