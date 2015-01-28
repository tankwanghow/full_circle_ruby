module PackagingsHelper
  def render_products_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'packagings/product_fields',
            headers: [['Product', 'span10'], ['Quantity', 'span6'], ['Unit', 'span4'], ['Cost', 'span6']],
            text: 'Add Product'
  end
end
