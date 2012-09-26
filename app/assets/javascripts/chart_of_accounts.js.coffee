window.chart_of_account = {
  init: ->
    ($ '#css-treeview-expand').click ->
      $('.css-treeview input[type=checkbox]').attr('checked', true)
    ($ '#css-treeview-collapse').click ->
      $('.css-treeview input[type=checkbox]').attr('checked', false)
    ($ 'form[admin_lock=true] input, form[admin_lock=true] select, form[admin_lock=true] textarea').attr('readOnly', true)
}