window.payment = {
  init: ->

    app.typeahead_init '#payment_pay_to_name1', '/account/typeahead_name1'
    app.typeahead_init '#payment_pay_from_name1', '/account/typeahead_name1'
    app.typeahead_init '#payment_collector', '/payment/typeahead_collector'
    app.typeahead_init '.particular_type', '/particular_type/typeahead_name'

    app.nestedFormFieldAdded 'form', '.row-fluid.nested', '.show-hide', (field) ->
      app.typeahead_init field.find('.particular_type'), '/particular_type/typeahead_name'

    app.nestedFormFieldRemoved 'form', '.row-fluid.nested', '.show-hide', '.fields:visible', '.row-total'

    ($ 'form').on 'blur', '#payment_pay_from_name1', ->
      if ($ this).val() is 'Cash in Hand'
        ($ '#payment_cheque_no, #payment_cheque_date').parents('.control-group').hide()
        ($ '#payment_cheque_no, #payment_cheque_date').val('')
      else
        ($ '#payment_cheque_no, #payment_cheque_date').parents('.control-group').show()
        ($ '#payment_cheque_no').select()

    math.rowTotal '.quantity', '.unit-price', '.row-total', '.fields', '.row-fluid.nested'

    math.sum '#payment_actual_debit_amount, #total_pay_from_particulars', '#payment_actual_credit_amount', 'form#payment_form'

    math.sum '.pay-to .row-total', '#payment_actual_debit_amount', 'form#payment_form'
    math.sum '.pay-from .row-total', '#total_pay_from_particulars', 'form#payment_form'

    app.showHide '.pay-to .fields:visible', '.pay-to .show-hide'
    app.showHide '.pay-from .fields:visible', '.pay-from .show-hide'
}

