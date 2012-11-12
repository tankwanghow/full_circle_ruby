window.cash_sale = {
  init: ->
    invoice.shared_init()
    cheque.init()
    app.showHide '#cheques .fields:visible', '#cheques .show-hide'
    math.sum '#total_details, #total_particulars', '#cash_sale_sales_amount', 'form#cashsale'
    math.sum '#cheques .amount', '#total_cheques', 'form#cashsale'
    app.typeahead_init '#cash_sale_customer_name1', '/account/typeahead_name1'
    ($ '.row-total').change()
    ($ '#cheques .amount').change()
}

