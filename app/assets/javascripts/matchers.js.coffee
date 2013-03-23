window.matchers = {
  init :->
    ($ '#matcher-query-btn').click (e) ->
      $.get '/matchers', 
        name1: ($ ($ '#matcher_account_element').val() ).val()
        doc_id: ($ '#matcher_doc_id').val()
        doc_type: ($ '#matcher_doc_type').val()
        from:($ '#matcher_from').val()
        to:($ '#matcher_to').val()
        , (data) -> 
          ($ '#matcher-data').html(data)
          ($ '.matching').change()
          app.initNumeric('.matching.numeric')
      e.preventDefault()

    ($ 'form').on 'click', '.auto_match', ->
      balance = +($ this).closest('.fields').find('.balance').val()
      ($ this).closest('.fields').find('.matching').val(-balance)
      ($ '.matching').change()

    ($ 'form').on 'change', '.matching', ->
      amount = +($ this).closest('.fields').find('.amount').val()
      matched = +($ this).closest('.fields').find('.matched').val()
      self_matched = +($ this).closest('.fields').find('.self_matched').val()
      matching = +($ this).val()
      balance = ($ this).closest('.fields').find('.balance')
      balance.val (amount + matched + matching + self_matched)
      if matching == 0
        ($ this).closest('.fields').find('[type=hidden][name*=_destroy]').val(true)
      else
        ($ this).closest('.fields').find('[type=hidden][name*=_destroy]').val(false)

}