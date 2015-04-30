window.invoice = {
  shared_init: ->

    particular.init()
    detail.init()

    ($ '#invoice_tag_list').select2
      tags: $('#invoice_tag_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2

    ($ '#invoice_loader_list').select2
      tags: $('#invoice_loader_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2

    ($ '#invoice_unloader_list').select2
      tags: $('#invoice_unloader_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2
    
    math.sum '#details .row-total', '#total_details', 'form'
    math.sum '#particulars .row-total', '#total_particulars', 'form'

    app.showHide '#details .fields:visible', '#details .show-hide'
    app.showHide '#particulars .fields:visible', '#particulars .show-hide'

  init: ->
    invoice.shared_init()
    math.sum '#total_details, #total_particulars', '#invoice_invoice_amount', 'form#invoice'
    app.typeahead_init '#invoice_customer_name1', '/account/typeahead_name1'
    app.typeahead_init '.tax_code', '/tax_code/typeahead_code'
    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide', (field) ->
      app.typeahead_init field.find('.tax_code'), '/tax_code/typeahead_code'
    ($ '.row-total').change()
}

