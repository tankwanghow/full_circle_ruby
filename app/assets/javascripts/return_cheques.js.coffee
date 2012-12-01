window.return_cheque = {
  init: ->
    app.typeahead_init '#return_cheque_return_to_name1', '/account/typeahead_name1'
    app.typeahead_init '#return_cheque_reason', '/return_cheque/typeahead_reason'

    ($ '#rtn-cheque-query-btn').click (e) ->
      $.get '/get_return_cheque', 
        return_to:($ '#return_cheque_return_to_name1').val()
        chq_no: ($ '#chq_no').val()
        bank: ($ '#bank').val()
        , (data) -> 
          if data
            ($ '#return_cheque_cheque_id').val(data.id)
            ($ '#return_cheque_return_from_name1').val(data.return_from_name1)
            ($ '#return_cheque_bank').val(data.bank)
            ($ '#return_cheque_chq_no').val(data.chq_no)
            ($ '#return_cheque_city').val(data.city)
            ($ '#return_cheque_state').val(data.state)
            ($ '#return_cheque_due_date').val(data.due_date)
            ($ '#return_cheque_amount').val(data.amount)
          else
            ($ '#return_cheque_cheque_id').val(null)
            ($ '#return_cheque_return_from_name1').val('Not Found!')
            ($ '#return_cheque_bank').val('Not Found!')
            ($ '#return_cheque_chq_no').val('Not Found!')
            ($ '#return_cheque_city').val('Not Found!')
            ($ '#return_cheque_state').val('Not Found!')
            ($ '#return_cheque_due_date').val('Not Found!')
            ($ '#return_cheque_amount').val('Not Found!')
      e.preventDefault()
}

