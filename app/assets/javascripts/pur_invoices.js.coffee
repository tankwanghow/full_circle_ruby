window.pur_invoice = {
  init: ->
    invoice.shared_init()
    
    ($ '#pur_invoice_tag_list').select2
      tags: $('#pur_invoice_tag_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2

    ($ '#pur_invoice_loader_list').select2
      tags: $('#pur_invoice_loader_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2

    ($ '#pur_invoice_unloader_list').select2
      tags: $('#pur_invoice_unloader_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2
    

    
    math.sum '#total_details, #total_particulars', '#pur_invoice_invoice_amount', 'form#invoice'
    app.typeahead_init '#pur_invoice_supplier_name1', '/account/typeahead_name1'
    ($ '.row-total').change()
}