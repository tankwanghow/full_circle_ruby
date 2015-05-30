module InvoicesHelper
  def render_invoice_details_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'details/field',
            headers: [['Product', 'span8'], ['Package', 'span4'], ['Pack', 'span3'], ['Note', 'span8'], ['Quantity', 'span4'],
                      ['Unit', 'span2'], ['Price', 'span3'], ['Discount', 'span3'], ['Code', 'span2'], ['GST %', 'span2'], 
                      ['GST', 'span3'], ['Amount', 'span4']],
            text: 'Add Detail'
  end

  def product_html_data builder
    { product_json: builder.object.product.to_json, source: Product.pluck(:name1), provide: 'typeahead' }
  end

  def packaging_html_data builder
    { package_json: builder.object.product_packaging.to_json, 
      source: ProductPackaging.pack_qty_names(builder.object.product.try(:id)), provide: 'typeahead' }
  end

  def render_matchers object
    total = 0
    if object.matchers.count > 0
      content_tag(:div, 'Matched Documents', class: :bold) +
      object.matchers.map do |t|
        total = total + t.amount
        content_tag :div, class: :span6 do
          link_to t.doc_type + docnolize(t.doc_id, ' #') + " " + t.amount.to_money.format, url_for(controller: t.doc_type.pluralize.underscore, action: :edit, id: t.doc_id)
        end
      end.join(' ').html_safe +
      content_tag(:div, "TOTAL = " + total.to_money.format, class: :bold)
    end
  end
end
