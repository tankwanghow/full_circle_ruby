$ ->
  app.standardInit()

  ($ 'a:not([data-remote]):not([data-behavior]):not([data-skip-pjax]):not([data-method="delete"])').pjax('[data-pjax-container]')

  $(document).on 'submit', 'form', (event) ->
    container = ($ '[data-pjax-container]')
    $.pjax.submit(event, container)

  ($ '[data-pjax-container]').on 'pjax:end', ->
    app.standardInit()

window.math = {

  rowTotal: (qtyCls, priceCls, totalCls, rowCls, evtBubbleCls) ->
    ($ evtBubbleCls).on 'blur', qtyCls, -> calRowTotal(this) # should use 'change' event but not all browser support it
    ($ evtBubbleCls).on 'blur', priceCls, -> calRowTotal(this) # should use 'change' event but not all browser support it

    calRowTotal = (elm) ->
      row_total = ($ elm).closest(rowCls).find(totalCls)
      qty = ($ elm).closest(rowCls).find(qtyCls).val()
      price = ($ elm).closest(rowCls).find(priceCls).val()
      row_total.val (qty * price).toFixed(2)
      row_total.trigger 'blur' # should use 'change' event but not all browser support it


  sum: (elements, totalElm, evtBubbleCls, checkVisible=true) ->
    ($ evtBubbleCls).on 'blur', elements, -> # should use 'change' event but not all browser support it
      total = 0
      ($ elements).each (index, elm) ->
        if checkVisible
          val = if ($ elm).is(":visible") then ($ elm).val() else 0
        else
          val = ($ elm).val()
        total = total + +val
      ($ totalElm).val total.toFixed(2)
      ($ totalElm).trigger 'blur' # should use 'change' event but not all browser support it
}

window.main = {

  init: ->
    ($ '#clear-advance-search-form').click ->
      ($ 'input#search_terms').val('')
      ($ 'input#search_date_from').val('')
      ($ 'input#search_date_to').val('')
      ($ 'input#search_amount_larger').val('')
      ($ 'input#search_amount_less').val('')
      ($ '#advance-search-form .simple_form').submit()

    if ($ 'input#search_terms:last').val() + ($ '#search_date_from').val() +
       ($ '#search_date_to').val() + ($ '#search_amount_larger').val() +
       ($ '#search_amount_less').val() isnt ""
      ($ '#advance-search-form').collapse('show')
}

window.app = {
  standardInit: ->
    app.initDatepicker()
    app.initNumeric()
    app.avoidAutocompleteForTypeahead()

  avoidAutocompleteForTypeahead: ->
    ($ 'input[data-provide="typeahead"]').attr('autocomplete', 'off')

  initNumeric: ->
    ($ 'input.numeric').numeric()

  initDatepicker: ->
    ($ 'input.datepicker').datepicker
      dateFormat: 'dd-mm-yy'
      buttonImage: '/assets/calendar-select.png'
      showOn: "button"
      buttonImageOnly: true

  nestedFormFieldAdded: (form, fields_parent, show_hide_elm) ->
    ($ form).on "nested:fieldAdded", (event) ->
      event.field.parents(fields_parent).find(show_hide_elm).show()
      event.field.find(':visible input:first').select()

  nestedFormFieldRemoved: (form, fields_parent, show_hide_elm, count_fields, trigger_blur_elements) ->
    ($ form).on "nested:fieldRemoved", (event) ->
      row_parent = event.field.parents(fields_parent)
      ($ trigger_blur_elements).trigger 'blur'
      if row_parent.find(count_fields).size() is 0
        row_parent.find(show_hide_elm).hide()

  showHide: (field_selector, showhide_selector) ->
    if ($ field_selector).size() > 0 
      ($ showhide_selector).show() 
    else
      ($ showhide_selector).hide()

}
