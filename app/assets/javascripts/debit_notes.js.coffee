window.debit_note = {

  init: ->
    
    math.sum '#particulars .row-total', '#total_particulars', 'form#debit_note'
    math.sum '.matching', '#total_matched', 'form#debit_note'
 
    app.typeahead_init '#debit_note_account_name1', '/account/typeahead_name1'

    credit_note.shared_init()

}

