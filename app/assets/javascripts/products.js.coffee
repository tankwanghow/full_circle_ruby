window.product = {
  init: ->

    ($ '#product_category_list').select2
      tags: $('#product_category_list').data('tags')
      closeOnSelect: true
      openOnEnter: false
      minimumInputLength: 2

    app.typeahead_init '#product_sale_account_name1', '/account/typeahead_name1'
    app.typeahead_init '#product_purchase_account_name1', '/account/typeahead_name1'
    app.typeahead_init '#product_supply_tax_code_code', '/tax_code/typeahead_code'
    app.typeahead_init '#product_purchase_tax_code_code', '/tax_code/typeahead_code'
    app.typeahead_init '.packaging', '/packaging/typeahead_name'

    app.nestedFormFieldAdded 'form', '.row-fluid.nested', '.show-hide', (field) ->
      app.typeahead_init field.find('.packaging'), '/packaging/typeahead_name'
}