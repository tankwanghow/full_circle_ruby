window.journal = {
  init: ->
    app.typeahead_init '.account', '/account/typeahead_name1'
    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide', (field) ->
      app.typeahead_init field.find('.account'), '/account/typeahead_name1'

    math.sum '#transactions .amount', '#total_transactions', 'form'

    ($ '.amount').change()
}

