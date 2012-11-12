window.cheque = {
  init: ->

    app.nestedFormFieldAdded 'form', '.row-fluid', '.show-hide'
    app.nestedFormFieldRemoved 'form', '.row-fluid', '.show-hide', '.fields:visible', '.row-total'

}