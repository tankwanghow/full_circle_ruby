window.cash_sale = {
  init: ->
    invoice.shared_init()
    cheque.init()

    ($ '#cash_sale_tag_list').select2
      tags: $('#cash_sale_tag_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2
    
    ($ '#cash_sale_loader_list').select2
      tags: $('#cash_sale_loader_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2

    ($ '#cash_sale_unloader_list').select2
      tags: $('#cash_sale_unloader_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2

    app.showHide '#cheques .fields:visible', '#cheques .show-hide'
    math.sum '#total_details, #total_particulars', '#cash_sale_sales_amount', 'form#cashsale'
    math.sum '#cheques .amount', '#total_cheques', 'form#cashsale'
    app.typeahead_init '#cash_sale_customer_name1', '/account/typeahead_name1'
    ($ '.row-total').change()
    ($ '#cheques .amount').change()
}

