window.pay_slip = {
  init: ->

    app.typeahead_init '#pay_slip_pay_from_name1', '/account/typeahead_name1'
    app.typeahead_init '.salary_type', '/salary_type/typeahead_name'

    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide', (field) ->
      app.typeahead_init field.find('.salary_type'), '/salary_type/typeahead_name'

    app.nestedFormFieldRemoved 'form', '.row-fluid', '.show-hide', '.fields:visible', '.row-total'

    app.standard_row_total_init()

    ($ 'form').on 'blur', '#pay_slip_pay_from_name1', ->
      if ($ this).val() is 'Cash in Hand'
        ($ '#pay_slip_chq_no').parents('.control-group').hide()
        ($ '#pay_slip_chq_no').val('')
      else
        ($ '#pay_slip_chq_no').parents('.control-group').show()
        ($ '#pay_slip_chq_no').select()

    ($ 'form').on 'change', '#notes .salary_type', ->
      elm = ($ this)
      $.get '/salary_type/json', { name: elm.val() }, (data) -> 
        row = elm.parents('.fields').find('.row-fluid')
        row.removeClass('Addition Deduction Contribution')
        row.addClass(data.classifiaction)
        elm.parents('.fields').find('.quantity').change()

    ($ 'form').on 'change', '.quantity, .unit-price', ->
      addition = pay_slip.sum_element('#notes .row-fluid.Addition .row-total')
      deduction = pay_slip.sum_element('#notes .row-fluid.Deduction .row-total')
      advance = pay_slip.sum_element('#advances .row-fluid.Advance .row-total')
      $('#total_advances').val(advance)
      $('#total_notes').val(addition - deduction)
      $('#total_pay').val(addition - deduction - advance)

    $('.quantity').change()

  sum_element: (selector) ->
    total = 0
    ($ selector).each (index, elm) ->
      val = if ($ elm).is(":visible") then ($ elm).val() else 0
      total = total + +val
    total.toFixed(2)

}