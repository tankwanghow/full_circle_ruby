window.asset = {
  init: ->
    app.showHide '#additions .fields:visible', '#additions .show-hide'
    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide'

  addition_init: ->
    app.showHide '#depreciations .fields:visible', '#depreciations .show-hide'
    app.showHide '#disposals .fields:visible', '#disposals .show-hide'
    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide'
}

