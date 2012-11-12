module InvoicesHelper
  def render_invoice_details_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'details/field',
            headers: [['Product', 'span4'], ['Package', 'span3'], ['Pack Qty', 'span2'], ['Note', 'span4'], 
                      ['Quantity', 'span2'], ['Unit', 'span2'], ['Price', 'span2'], ['Amount', 'span3']],
            text: 'Add Detail'
  end

  def product_html_data builder
    { product_json: builder.object.product.to_json, source: Product.pluck(:name1), provide: 'typeahead' }
  end

  def packaging_html_data builder
    { package_json: builder.object.product_packaging.to_json, 
      source: ProductPackaging.pack_qty_names(builder.object.product.try(:id)), provide: 'typeahead' }
  end  
end
