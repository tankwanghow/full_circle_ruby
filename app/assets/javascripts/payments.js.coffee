window.payment = {

  shared_init: ->

    app.typeahead_init '#payment_pay_to_name1', '/account/typeahead_name1'
    app.typeahead_init '#payment_pay_from_name1', '/account/typeahead_name1'
    app.typeahead_init '#payment_collector', '/payment/typeahead_collector'

    particular.init()

    ($ 'form').on 'blur', '#payment_pay_from_name1', ->
      if ($ this).val() is 'Cash In Hand'
        ($ '#payment_cheque_no, #payment_cheque_date').parents('.control-group').hide()
        ($ '#payment_cheque_no, #payment_cheque_date').val('')
      else
        ($ '#payment_cheque_no, #payment_cheque_date').parents('.control-group').show()
        ($ '#payment_cheque_no').select()

    math.sum '#payment_actual_debit_amount, #total_pay_from_particulars', '#payment_actual_credit_amount', 'form#payment_form'
    math.sum '#pay-from .row-total', '#total_pay_from_particulars', 'form#payment_form'

    app.showHide '#pay-from-particulars .fields:visible', '#pay-from-particulars .show-hide'

  init: ->

    payment.shared_init()
    app.showHide '#pay-to-particulars .fields:visible', '#pay-to-particulars .show-hide'
    math.sum '#pay-to .row-total', '#payment_actual_debit_amount', 'form#payment_form'
    app.standard_row_total_init()
    ($ '.row-total').change()

}