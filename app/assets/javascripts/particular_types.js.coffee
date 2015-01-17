window.particular_type = {
  init: ->
    app.typeahead_init '#particular_type_supply_tax_code_code', '/tax_code/typeahead_code'
    app.typeahead_init '#particular_type_purchase_tax_code_code', '/tax_code/typeahead_code'
}