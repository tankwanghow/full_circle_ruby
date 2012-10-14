window.packaging = {
  init: ->

    ($ 'form').on 'blur', '#products .product', ->
      elm = ($ this)
      $.get '/product/get_unit', { name1: elm.val() }, (data) -> 
        elm.parents('.fields').find('[name="row_unit"]').val(data)
}

