window.advance = {

  init: ->

    app.typeahead_init '#advance_pay_from_name1', '/account/typeahead_name1'
    app.typeahead_init '#advance_employee_name', '/employee/typeahead_name'

    ($ 'form').on 'blur', '#advance_pay_from_name1', ->
      if ($ this).val() is 'Cash In Hand'
        ($ '#advance_chq_no').parents('.control-group').hide()
        ($ '#advance_chq_no').val('')
      else
        ($ '#advance_chq_no').parents('.control-group').show()
        ($ '#advance_chq_no').select()

}