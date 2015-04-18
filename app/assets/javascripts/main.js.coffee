$ ->
  app.standardInit()
  app.standard_row_total_init()

  ($ '[data-pjax-container]').on 'pjax:start', ->
    ($ 'body').css('cursor', 'wait')

  $(document).on 'click', 'a:not([data-remote]):not([data-behavior]):not([data-skip-pjax]):not([data-method])', (event) ->
    container = $('[data-pjax-container]')
    $.pjax.click(event, container)

  $(document).on 'submit', 'form:not([data-skip-pjax])', (event) ->
    container = ($ '[data-pjax-container]')
    val = $("input[type=submit][clicked=true]").val()
    $(event.currentTarget).append("<input type='hidden' name='submit' value='#{val}'>")
    $("input[type=submit][clicked=true]").removeAttr('clicked')
    $.pjax.submit(event, container)

  ($ '[data-pjax-container]').on 'pjax:end', ->
    ($ 'body').css('cursor', 'default')
    $('.alert, .no-record').fadeIn(1000)
    app.standardInit()

  $('.alert, .no-record').fadeIn(1000)

window.math = {

  rowTotal: (qtyCls, priceCls, discountCls, gstRateCls, gstCls, totalCls, rowCls, evtBubbleCls) ->
    ($ evtBubbleCls).on 'change', qtyCls,      -> calRowTotal(this)
    ($ evtBubbleCls).on 'change', priceCls,    -> calRowTotal(this)
    ($ evtBubbleCls).on 'change', discountCls, -> calRowTotal(this)
    ($ evtBubbleCls).on 'change', gstRateCls,  -> calRowTotal(this)

    calRowTotal = (elm) ->
      row_total = ($ elm).closest(rowCls).find(totalCls)
      gst       = ($ elm).closest(rowCls).find(gstCls)
      qty       = + ($ elm).closest(rowCls).find(qtyCls).val() || 0
      price     = + ($ elm).closest(rowCls).find(priceCls).val() || 0
      discount  = + ($ elm).closest(rowCls).find(discountCls).val() || 0
      gst_rate  = + ($ elm).closest(rowCls).find(gstRateCls).val() || 0

      amount   = (qty * price) + discount
      gst_val  = amount * (gst_rate / 100)

      gst.val((Math.round(gst_val * 100)/100).toFixed(2)) if gst
      row_total.val (Math.round((amount + gst_val)*100)/100).toFixed(2)
      gst.change()
      row_total.change()


  sum: (elements, totalElm, evtBubbleCls, checkVisible=true) ->
    ($ evtBubbleCls).on 'change', elements, ->
      total = 0
      ($ elements).each (index, elm) ->
        if checkVisible
          val = if ($ elm).is(":visible") then ($ elm).val() else 0
        else
          val = ($ elm).val()
        total = total + +val
      ($ totalElm).val total.toFixed(2)
      ($ totalElm).change()
}

window.main = {

  init: ->
    ($ '#clear-advance-search-form').click ->
      ($ 'input#search_terms').val('')
      ($ 'input#search_date_from').val('')
      ($ 'input#search_date_to').val('')
      ($ 'input#search_amount_larger').val('')
      ($ 'input#search_amount_smaller').val('')
      ($ 'input#search_posted').val('')
      ($ '#advance-search-form .simple_form').submit()

    if ($ 'input#search_terms:last').val() + ($ '#search_date_from').val() +
       ($ '#search_date_to').val() + ($ '#search_amount_larger').val() +
       ($ '#search_amount_less').val() isnt ""
      ($ '#advance-search-form').collapse('show')
}

window.app = {
  standardInit: ->
    ($ 'form[admin_lock=true] input, form[admin_lock=true] select, form[admin_lock=true] textarea').attr('disabled', true)
    ($ 'form[posted_lock=true] input, form[posted_lock=true] select, form[posted_lock=true] textarea').attr('disabled', true)
    ($ 'form input[type=submit]').click ->
      ($ this).attr('clicked', true)
    app.initDatepicker()
    app.initNumeric()
    app.avoidAutocompleteForTypeahead()

  avoidAutocompleteForTypeahead: ->
    ($ 'input.string[type="text"]').attr('autocomplete', 'off')

  initNumeric: (selector = 'input.numeric:not([readonly])')->
    ($ selector).on 'change', ->
      unless /[a-zA-Z]+/.test(($ this).val())
        try
          val = eval ($ this).val()
          ($ this).val(val)
          ($ this).parents('.control-group').removeClass('error')
        catch err
          ($ this).parents('.control-group').addClass('error')

  initDatepicker: ->
    ($ 'input.datepicker:not([readonly])').datepicker
      dateFormat: 'dd-mm-yy'
      buttonImage: '/assets/calendar-select.png'
      showOn: "button"
      buttonImageOnly: true

  nestedFormFieldAdded: (form, fields_parent, show_hide_elm, func) ->
    ($ form).on "nested:fieldAdded", (event) ->
      func(event.field) if func
      event.field.closest(fields_parent).find(show_hide_elm).show()
      event.field.find(':visible input:first').select()
      app.standardInit()

  nestedFormFieldRemoved: (form, fields_parent, show_hide_elm, count_fields, trigger_blur_elements) ->
    ($ form).on "nested:fieldRemoved", (event) ->
      row_parent = event.field.closest(fields_parent)
      ($ trigger_blur_elements).change()
      if row_parent.find(count_fields).size() is 0
        row_parent.find(show_hide_elm).hide()

  showHide: (field_selector, showhide_selector) ->
    if ($ field_selector).size() > 0
      ($ showhide_selector).show()
    else
      ($ showhide_selector).hide()

  standard_row_total_init: ->
    math.rowTotal '.quantity', '.unit-price', '.discount', '.gst_rate', '.gst', '.row-total', '.fields', '.row-fluid'

  typeahead_init: (selector, url, params_func= -> {}) ->
    if selector.jquery
      elms = selector
    else
      elms = $(selector)

    ($ elms).each (index, elm) ->
      ($ elm).typeahead
        source: (q, p) -> $.get url, $.extend({ term: q }, params_func($ elm)), (data) -> p(data)
        matcher: -> true
}
