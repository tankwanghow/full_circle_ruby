$ ->
  ($ '.css-treeview label[data-selected=true], .css-treeview a[data-selected=true]').click()

  ($ '.css-treeview .account_type').click ->
    displaySelected(this)
    parent_id = $('label.label-warning').data('id')
    setParentId parent_id
    displayEditAccountType $(this)

  ($ '.css-treeview .account').click ->
    displaySelected(this)
    parent_id = $('a.label-warning').data('parent-id')
    setParentId parent_id
    displayEditAccount $(this)    

  ($ '#css-treeview-expand').click ->
    $('.css-treeview input[type=checkbox]').attr('checked', true)
  ($ '#css-treeview-collapse').click ->
    $('.css-treeview input[type=checkbox]').attr('checked', false)

  $('#chart-of-accounts a#new-account-type').click (e) ->
    displayNewAccountType($(this))

  $('#chart-of-accounts a#new-account').click (e) ->
    displayNewAccount($(this))

  displayNewAccountType = (element) ->
    $.get element.data('url'), 
      { parent_id: element.data('parent_id') },
      (data) -> ($ '#form-area').html(data)

  displayEditAccountType = (element) ->
    $.get element.data('url'), 
      (data) -> ($ '#form-area').html(data)

  displayNewAccount = (element) ->
    $.get element.data('url'), 
      { account_type_id: element.data('parent_id') },
      (data) -> ($ '#form-area').html(data)

  displayEditAccount = (element) ->
    $.get element.data('url'), 
      (data) -> ($ '#form-area').html(data)

  displaySelected = (element) ->
    $('label.label-warning').addClass 'label-info'
    $('a.label-warning').addClass 'label-success'
    $('label.label-warning').removeClass 'label-warning'
    $('a.label-warning').removeClass 'label-warning'
    if $(element).is('label')
      $(element).removeClass 'label-info'
    else
      $(element).removeClass 'label-success'
    $(element).addClass 'label-warning'

  setParentId = (parent_id) ->
    $('#chart-of-accounts a#new-account-type').data('parent_id', parent_id)
    $('#chart-of-accounts a#new-account').data('parent_id', parent_id)

  ($ '.css-treeview label[data-selected=true], .css-treeview a[data-selected=true]').click()