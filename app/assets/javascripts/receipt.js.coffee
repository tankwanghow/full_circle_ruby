window.receipt = {
  init: ->
    cheque.init()
    matchers.init()
    app.showHide '#cheques .fields:visible', '#cheques .show-hide'
    math.sum '#total_cheques, #receipt_cash_amount', '#receipt_receipt_amount', 'form#receipt'
    math.sum '#cheques .amount', '#total_cheques', 'form#receipt'
    math.sum '.matching', '#total_matched', 'form#receipt'
    app.typeahead_init '#receipt_receive_from_name1', '/account/typeahead_name1'
    ($ '#cheques .amount').change()
    ($ '.matching').change()
}

