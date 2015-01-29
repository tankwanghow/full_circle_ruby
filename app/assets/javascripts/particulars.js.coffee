window.particular = {
  init: ->

    app.typeahead_init '#particulars .particular_type', '/particular_type/typeahead_name'
    
    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide', (field) ->
      app.typeahead_init field.find('.particular_type'), '/particular_type/typeahead_name'

    ($ 'form').on 'change', '#particulars .particular_type', ->
      elm = ($ this)
      $.get '/particular_type/json', { name: elm.val(), gst_type: elm.parents('form').data('gst-type') }, (data) -> 
        elm.parents('.fields').find('.tax_code').val(data.tax_code)
        elm.parents('.fields').find('.tax_code').change()

    ($ 'form').on 'change', '#particulars .tax_code, #pay-to-particulars .tax_code, #pay-from-particulars .tax_code', ->
      elm = ($ this)
      $.get '/tax_code/json', { code: elm.val() }, (data) -> 
        elm.parents('.fields').find('.gst_rate').val(data.rate)    
        elm.parents('.fields').find('.gst_rate').change()

    app.nestedFormFieldRemoved 'form', '.row-fluid', '.show-hide', '.fields:visible', '.row-total'

}