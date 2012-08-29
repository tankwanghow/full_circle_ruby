window.payment = {
  init: -> 
    
    ($ "form").on "nested:fieldAdded", (event) ->
      event.field.parents('.row.nested').find('.show-hide').show()

    ($ "form").on "nested:fieldRemoved", (event) ->
      row_parent = event.field.parents('.row.nested')
      if row_parent.find('.fields:visible').size() is 0
        row_parent.find('.show-hide').hide()
    
    math.rowTotal '.quantity', '.unit-price', '.row-total', '.fields', '.row.nested'
    
    math.sum '.pay-to .row-total', '#total_pay_to_particulars', '.pay-to'
    math.sum '.pay-from .row-total', '#total_pay_from_particulars', '.pay-from'

    math.sum '#payment_pay_amount, #total_pay_to_particulars', '#payment_actual_debit_amount', 'form#payment_form'
    math.sum '#payment_actual_debit_amount, #total_pay_from_particulars', '#payment_actual_credit_amount', 'form#payment_form'
}