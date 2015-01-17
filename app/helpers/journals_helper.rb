module JournalsHelper
  def render_journal_transaction_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'journals/transaction_fields',
            headers: [['Account', 'span6'], ['Note', 'span11'], ['Amount', 'span4']],
            text: 'Add Transaction'
  end

end
