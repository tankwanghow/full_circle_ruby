window.product_sales_report = {
  init: ->
    ($ '#options_doc_tags').select2
      tags: $('#options_doc_tags').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2
    ($ '#options_product_tags').select2
      tags: $('#options_product_tags').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2
}

window.sales_amount_report = {
  init: ->
    ($ '#options_doc_tags').select2
      tags: $('#options_doc_tags').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2
}