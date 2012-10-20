window.packaging = {
  init: ->

    ($ 'form').on 'change ', '#products .product', ->
      elm = ($ this)
      $.get '/product/json', { name1: elm.val() }, (data) -> 
        elm.parents('.fields').find('[name="row_unit"]').val(data.unit)

    app.typeahead_init '.product', '/product/typeahead_name1'

    app.nestedFormFieldAdded 'form', '.row-fluid.nested', '.show-hide', (field) ->
      app.typeahead_init field.find('.product'), '/product/typeahead_name1'
}

