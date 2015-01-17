module PaySlipsHelper
  def render_salary_notes_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'pay_slips/salary_note_field',
           headers: [['Date', 'span3'], ['Doc No', 'span2'], ['Type', 'span4'], ['Note', 'span4'],
                      ['Quantity', 'span2'], ['Unit', 'span2'], ['Price', 'span2'], ['Amount', 'span3']],
           text: 'Add Note'
  end

  def render_advances_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'pay_slips/advance_field',
           headers: [['Date', 'offset14 span3'], ['Advance No', 'span2'], ['Amount', 'span3']],
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
