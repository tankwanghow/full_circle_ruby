window.pur_invoice = {
  init: ->
    invoice.shared_init()
    math.sum '#total_invoice_details, #total_particulars', '#pur_invoice_invoice_amount', 'form#invoice'
    app.typeahead_init '#pur_invoice_supplier_name1', '/account/typeahead_name1'
    ($ '.row-total').trigger('change')
}

