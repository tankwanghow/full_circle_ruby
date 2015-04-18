window.salary_note = {
  init: ->
    app.typeahead_init '#salary_note_employee_name', '/employee/typeahead_name'
    app.typeahead_init '#salary_note_salary_type_name', '/salary_type/typeahead_name'

    ($ 'form').on 'change', '#salary_note_quantity, #salary_note_unit_price', ->
      qty = +($ '#salary_note_quantity').val() 
      price = +($ '#salary_note_unit_price').val()
      ($ '#salary_note_amount').val math.round(qty * price, 2)
}