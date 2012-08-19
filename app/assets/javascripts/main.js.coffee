$ ->
  ($ '.datepicker').datepicker
      dateFormat: 'dd-mm-yy'

  for tah in ($ 'input.typeahead')
    jqtah = ($ tah)
    source_with_id = jqtah.data('source-with-id')
    display_name = jqtah.data('display-name')
    id_element = $('#' + jqtah.data('id-element'))

    jqtah.data('source', $.map source_with_id, (val, index) -> val[display_name])

    matched_elements = $.grep(source_with_id, (ele) -> ele['id'] is parseInt id_element.val())
    if matched_elements.length > 0
      jqtah.val matched_elements[0][display_name]

    jqtah.change -> setIdElement($ this)

  if ($ '#search_date_from').val() isnt "" or ($ '#search_date_to').val() isnt "" or ($ '#search_amount_larger').val() isnt "" or ($ '#search_amount_less').val() isnt ""
    ($ '#advance-search-form').collapse('show')

  ($ '#clear-advance-search-form').click ->
    ($ '#search_date_from').val('') 
    ($ '#search_date_to').val('') 
    ($ '#search_amount_larger').val('') 
    ($ '#search_amount_less').val('')

  setIdElement = (element) ->
    id_element = $('#' + element.data('id-element'))
    source_with_id = element.data('source-with-id')
    display_name = element.data('display-name')
    matched_elements = $.grep(source_with_id, (ele) -> ele[display_name] is element.val())
    if matched_elements.length > 0
      id_element.val matched_elements[0]['id']