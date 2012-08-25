$ ->
  ($ 'a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]')

window.math = {

  rowTotal: (qtyCls, priceCls, rowCls, totalCls) ->    
    ($ 'form#payment_form').on 'change', qtyCls, -> calRowTotal(this)
    ($ 'form#payment_form').on 'change', priceCls, -> calRowTotal(this)

    calRowTotal = (elm) ->
      row_total = ($ elm).closest(rowCls).find(totalCls)
      qty = ($ elm).closest(rowCls).find(qtyCls).val()
      price = ($ elm).closest(rowCls).find(priceCls).val()
      row_total.val (qty * price).toFixed(2)
      row_total.trigger "change"


  sum: (elements, totalElm, checkVisible=true) ->
    ($ elements).on 'change', ->
      total = 0
      _.each ($ elements), (elm)->
        if checkVisible
          val = if ($ elm).is(":visible") then ($ elm).val() else 0
        else
          val = ($ elm).val()
        total = total + +val
      ($ totalElm).val total.toFixed(2)
      ($ totalElm).trigger "change"
}

window.main = {

  init: ->
    ($ '#clear-advance-search-form').click ->
      ($ 'input#search_terms').val('')
      ($ 'input#search_date_from').val('')
      ($ 'input#search_date_to').val('')
      ($ 'input#search_amount_larger').val('')
      ($ 'input#search_amount_less').val('')

    app.initDatepicker()

    if ($ '#search_date_from').val() isnt "" or ($ '#search_date_to').val() isnt "" or ($ '#search_amount_larger').val() isnt "" or ($ '#search_amount_less').val() isnt ""
      ($ '#advance-search-form').collapse('show')

}

window.app = {
  initDatepicker: ->
    ($ 'input.datepicker').datepicker
      dateFormat: 'dd-mm-yy'
      buttonImage: '/assets/calendar-select.png'
      showOn: "button"
      buttonImageOnly: true  
}