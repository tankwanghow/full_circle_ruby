window.detail = {
  init: ->

    app.typeahead_init '#details .product', '/product/typeahead_name1'

    ($ 'form').on 'change', '#details .package_qty', ->
      pack_data = ($ this).parents('.fields').find('.packaging').data('package-json')
      qty_elm = ($ this).parents('.fields').find('.quantity')
      if pack_data
        qty_elm.val( pack_data.quantity * ($ this).val() )
      else
        qty_elm.val( 0 * ($ this).val() )
      qty_elm.change()

    app.typeahead_init '#details .packaging', '/packaging/typeahead_product_package_name', (elm) ->
      product_json = elm.parents('.fields').find('.product').data('product-json')
      { product_id: product_json.id } if product_json

    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide', (field) ->
      app.typeahead_init field.find('.product'), '/product/typeahead_name1'
      app.typeahead_init field.find('.packaging'), "/packaging/typeahead_product_package_name", ->
        product_json = field.find('.product').data('product-json')
        { product_id: product_json.id } if product_json

    ($ 'form').on 'change', '#details .tax_code', ->
      elm = ($ this)
      $.get '/tax_code/json', { code: elm.val() }, (data) -> 
        elm.parents('.fields').find('.gst_rate').val(data.rate)    
        elm.parents('.fields').find('.gst_rate').change()

    ($ 'form').on 'change', '#details .product', ->
      elm = ($ this)
      $.get '/product/json', { name1: elm.val(), gst_type: elm.parents('form').data('gst-type') }, (data) -> 
        elm.parents('.fields').find('[name="row_unit"]').val(data.unit)
        elm.parents('.fields').find('.tax_code').val(data.tax_code)
        elm.parents('.fields').find('.packaging').val(data.first_packaging_name)
        elm.data('product-json', data)
        elm.parents('.fields').find('.packaging').change()
        elm.parents('.fields').find('.tax_code').change()

    ($ 'form').on 'change', '#details .packaging', ->
      elm = ($ this)
      product_json = elm.parents('.fields').find('.product').data('product-json')
      if product_json
        $.get '/packaging/json', { product_id: product_json.id, name: elm.val() }, (data) -> 
          elm.data('package-json', data)
          if not data
            elm.parents('.fields').find('.package_qty').val('0.00')
            elm.parents('.fields').find('.package_qty').attr('disabled', false)
          else
            elm.parents('.fields').find('.package_qty').removeAttr('disabled')
      elm.parents('.fields').find('.package_qty').change()

}