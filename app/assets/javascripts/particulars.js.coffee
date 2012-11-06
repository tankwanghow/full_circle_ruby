window.particular = {
  init: ->

    app.typeahead_init '.particular_type', '/particular_type/typeahead_name'
    
    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide', (field) ->
      app.typeahead_init field.find('.particular_type'), '/particular_type/typeahead_name'

    app.nestedFormFieldRemoved 'form', '.row-fluid', '.show-hide', '.fields:visible', '.row-total'

}