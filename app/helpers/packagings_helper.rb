module PackagingsHelper
  def render_products_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'packagings/product_fields',
            headers: [['Product', 'span5'], ['Quantity', 'span3'], ['Unit', 'span2'], ['Cost', 'span3']],
            text: 'Add Product'
  end
end
