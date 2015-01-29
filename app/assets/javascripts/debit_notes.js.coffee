window.debit_note = {

  init: ->
    
    math.sum '#particulars .row-total', '#total_particulars', 'form#debit_note'
    math.sum '.matching', '#total_matched', 'form#debit_note'
 
    app.typeahead_init '#debit_note_account_name1', '/account/typeahead_name1'
    app.typeahead_init '.tax_code', '/tax_code/typeahead_purchase_code'
    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide', (field) ->
      app.typeahead_init field.find('.tax_code'), '/tax_code/typeahead_code'

    credit_note.shared_init()

}

