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
    
    math.sum '#pay-from .gst', '#total_pay_from_gst', 'form#payment'
    math.sum '#pay-from .row-total', '#total_pay_from_particulars', 'form#payment'

    app.showHide '#pay-from-particulars .fields:visible', '#pay-from-particulars .show-hide'

    math.sum '#total_pay_to_gst, #payment_actual_debit_amount, #total_pay_from_particulars, #total_pay_from_gst',
             '#payment_actual_credit_amount', 'form#payment'

  init: ->

    payment.shared_init()
    
    app.typeahead_init '.tax_code', '/tax_code/typeahead_purchase_code'
    
    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide', (field) ->
      app.typeahead_init field.find('.tax_code'), '/tax_code/typeahead_purchase_code'
    
    math.sum '#pay-to .gst', '#total_pay_to_gst', 'form#payment'
    math.sum '#pay-to .row-total', '#total_pay_to_particulars', 'form#payment'

    app.showHide '#pay-to-particulars .fields:visible', '#pay-to-particulars .show-hide'

    ($ 'form#payment').on 'change', '#total_pay_to_particulars', -> 
      total = + ($ '#total_pay_to_particulars').val()
      gst   = - ($ '#total_pay_to_gst') .val()
      ($ '#payment_actual_debit_amount').val((total + gst).toFixed(2))
      ($ '#payment_actual_debit_amount').change()

    ($ '.row-total').change()

}