window.payment = {
  init: -> 
    ($ "form").on "nested:fieldAdded", (event) ->
      event.field.parents('.row.nested').find('.show-hide').show()

    ($ "form").on "nested:fieldRemoved", (event) ->
      row_parent = event.field.parents('.row.nested')
      if row_parent.find('.fields:visible').size() is 0
        row_parent.find('.show-hide').hide()
    
    math.rowTotal '.quantity', '.unit-price', '.fields', '.row_total'
}