window.invoice = {
  init: ->

    ($ 'form').on 'change', '#details .package_qty', ->
      pack_data = ($ this).parents('.fields').find('.packaging').data('package-json')
      qty_elm = ($ this).parents('.fields').find('.quantity')
      if pack_data
        qty_elm.val( pack_data.quantity * ($ this).val() )
      else
        qty_elm.val( 0 * ($ this).val() )
      qty_elm.change()

    app.typeahead_init '#invoice_customer_name1', '/account/typeahead_name1'
    app.typeahead_init '#details .product', '/product/typeahead_name1'
    app.typeahead_init '#particulars .particular_type', '/particular_type/typeahead_name'

    app.typeahead_init '#details .packaging', '/packaging/typeahead_product_package_name', (elm) ->
      product_json = elm.parents('.fields').find('.product').data('product-json')
      { product_id: product_json.id } if product_json


    app.nestedFormFieldAdded 'form', '.row-fluid.nested', '.show-hide', (field) ->
      app.typeahead_init field.find('.product'), '/product/typeahead_name1'
      app.typeahead_init field.find('.particular_type'), '/particular_type/typeahead_name'
      app.typeahead_init field.find('.packaging'), "/packaging/typeahead_product_package_name", ->
        product_json = field.find('.product').data('product-json')
        { product_id: product_json.id } if product_json

    app.nestedFormFieldRemoved 'form', '.row-fluid.nested', '.show-hide', '.fields:visible', '.row-total'

    math.rowTotal '.quantity', '.unit-price', '.row-total', '.fields', '.row-fluid.nested'

    math.sum '#total_invoice_details, #total_particulars', '#invoice_invoice_amount', 'form#invoice'

    math.sum '#details .row-total', '#total_invoice_details', 'form#invoice'
    math.sum '#particulars .row-total', '#total_particulars', 'form#invoice'

    app.showHide '#details .fields:visible', '#details .show-hide'
    app.showHide '#particulars .fields:visible', '#particulars .show-hide'

    ($ 'form').on 'change', '#details .product', ->
      elm = ($ this)
      $.get '/product/json', { name1: elm.val() }, (data) -> 
        elm.parents('.fields').find('[name="row_unit"]').val(data.unit)
        elm.parents('.fields').find('.packaging').val('')
        elm.data('product-json', data)
        elm.parents('.fields').find('.packaging').change()

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

