window.matching_payment = {
  init: ->
    payment.shared_init()
    matchers.init()
    math.sum '#pay-to .matching', '#payment_actual_debit_amount', 'form#payment_form'
    ($ '.row-total').change()
    ($ '.matching').change()
}