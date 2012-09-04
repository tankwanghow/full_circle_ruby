window.payment = {
  init: -> 
    
    ($ "form").on "nested:fieldAdded", (event) ->
      event.field.parents('.row.nested').find('.show-hide').show()

    ($ "form").on "nested:fieldRemoved", (event) ->
      row_parent = event.field.parents('.row.nested')
      ($ '.row-total').trigger 'change' # to update total_pay_from_particulars
      if row_parent.find('.fields:visible').size() is 0
        row_parent.find('.show-hide').hide()

    ($ 'form').on 'blur', '#payment_pay_from_name1', ->
      if ($ this).val() is 'Cash in Hand'
        ($ '#payment_cheque_no, #payment_cheque_date').parents('.control-group').hide()
        ($ '#payment_cheque_no, #payment_cheque_date').val('')
      else
        ($ '#payment_cheque_no, #payment_cheque_date').parents('.control-group').show()
        ($ '#payment_cheque_no').focus()
    
    math.rowTotal '.quantity', '.unit-price', '.row-total', '.fields', '.row.nested'
    math.sum '.pay-from .row-total', '#total_pay_from_particulars', '.pay-from'
    math.sum '#payment_pay_amount, #total_pay_from_particulars', '#payment_actual_credit_amount', 'form#payment_form'

    if ($ '.fields:visible').size() > 0
      ($ '.show-hide').show() 
    else 
      ($ '.show-hide').hide()
}