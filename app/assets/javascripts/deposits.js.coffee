window.deposit = {
  init: ->
    cheque.init()
#    app.showHide '#cheques .fields:visible', '#cheques .show-hide'
    math.sum '#cheque-data .amount', '#total_cheques', 'form#deposit'
    app.typeahead_init '#deposit_bank_name1', '/account/typeahead_name1'
    ($ '#cheque-data .amount').change()

    ($ '#cheque-query-btn').click (e) ->
      $.get '/cheques', 
        due_date:($ '#due_date').val()
        doc_id: ($ '#doc_id').val()
        doc_type: ($ '#doc_type').val()
        limit: ($ '#limit').val()
        , (data) -> 
          ($ '#cheque-data').html(data)
          ($ '#cheque-data .amount').change()
          ($ 'h4.no-record').slideDown 1000
      e.preventDefault()
}

