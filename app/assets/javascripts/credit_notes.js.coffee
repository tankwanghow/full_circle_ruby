window.credit_note = {

  init: ->
    math.sum '#particulars .row-total', '#total_particulars', 'form#credit_note'
    math.sum '.matching', '#total_matched', 'form#credit_note'
 
    app.typeahead_init '#credit_note_account_name1', '/account/typeahead_name1'
    app.typeahead_init '.tax_code', '/tax_code/typeahead_purchase_code'
    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide', (field) ->
      app.typeahead_init field.find('.tax_code'), '/tax_code/typeahead_code'

    credit_note.shared_init()


  shared_init: ->
    particular.init()
    matchers.init()
    app.showHide '#particulars .fields:visible', '#particulars .show-hide'
    ($ '.row-total').change() 
    ($ '.matching').change()
}

