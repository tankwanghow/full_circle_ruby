module PaySlipsHelper
  def render_salary_notes_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'pay_slips/salary_note_field',
           headers: [['Date', 'span6'], ['Doc No', 'span4'], ['Type', 'span8'], ['Note', 'span8'],
                      ['Quantity', 'span4'], ['Unit', 'span4'], ['Price', 'span4'], ['Amount', 'span6']],
           text: 'Add Note'
  end

  def render_advances_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'pay_slips/advance_field',
           headers: [['Date', 'offset28 span6'], ['Advance No', 'span4'], ['Amount', 'span6']],
           text: 'Add Advance', can_add_row: false
  end

  def salary_note_lock? note
    if note.harvesting_slip || note.pay_slip
      true
    else
      false
    end
  end
end
