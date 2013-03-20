module LayersHelper
  def render_eggs_harvesting_wages_fields builder, xies_name, with_type=true
    headers = [['Prod 1', 'span3'], ['Prod 2', 'span3'], ['Wages', 'span3']]
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'houses/egg_harvesting_wage_fields',
            headers: headers, with_type: with_type, text: 'Add Wages'
  end

  def render_movement_fields builder, xies_name, with_type=true
    headers = [['Move Date', 'span3'], ['House', 'span3'], ['Quantity', 'span3'], ['Note', 'span5'], ['Current Qty', 'span3']]
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'flocks/movement_fields',
            headers: headers, with_type: with_type, text: 'Add Move'
  end

  def render_harvest_detail_fields builder, xies_name, with_type=true
    headers = [['House', 'span2'], ['Flock', 'span4'], ['Prod 1', 'span2'], ['Prod 2', 'span2'], ['Death', 'span2'], ['Note', 'span4']]
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'harvesting_slips/harvest_detail_fields',
            headers: headers, with_type: with_type, text: 'Add House'
  end

  def harvesting_slip_lock? slip
    if slip.salary_note.pay_slip
      true
    else
      false
    end
  end
end