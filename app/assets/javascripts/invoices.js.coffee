window.invoice = {
  shared_init: ->

    particular.init()
    detail.init()
    app.standard_row_total_init()
    
    math.sum '#details .row-total', '#total_invoice_details', 'form#invoice'
    math.sum '#particulars .row-total', '#total_particulars', 'form#invoice'

    app.showHide '#details .fields:visible', '#details .show-hide'
    app.showHide '#particulars .fields:visible', '#particulars .show-hide'

  init: ->
    invoice.shared_init()
    math.sum '#total_invoice_details, #total_particulars', '#invoice_invoice_amount', 'form#invoice'
    app.typeahead_init '#invoice_customer_name1', '/account/typeahead_name1'
    ($ '.row-total').trigger('change')
}

