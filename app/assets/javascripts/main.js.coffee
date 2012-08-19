$ ->
  ($ '.datepicker').datepicker
      dateFormat: 'dd-mm-yy'

  if ($ '#search_date_from').val() isnt "" or ($ '#search_date_to').val() isnt "" or ($ '#search_amount_larger').val() isnt "" or ($ '#search_amount_less').val() isnt ""
    ($ '#advance-search-form').collapse('show')

  ($ '#clear-advance-search-form').click ->
    ($ '#search_date_from').val('') 
    ($ '#search_date_to').val('') 
    ($ '#search_amount_larger').val('') 
    ($ '#search_amount_less').val('')