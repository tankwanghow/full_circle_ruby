window.transaction = {
  init: ->
    $('#transaction-search-form').collapse 'show'
    app.typeahead_init '#transactions_query_name', '/account/typeahead_name1'
}
