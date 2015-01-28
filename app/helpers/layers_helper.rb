module LayersHelper
  def render_eggs_harvesting_wages_fields builder, xies_name, with_type=true
    headers = [['Prod 1', 'span6'], ['Prod 2', 'span6'], ['Wages', 'span6']]
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'houses/egg_harvesting_wage_fields',
            headers: headers, with_type: with_type, text: 'Add Wages'
  end

  def render_movement_fields builder, xies_name, with_type=true
    headers = [['Move Date', 'span6'], ['House', 'span6'], ['Quantity', 'span6'], ['Note', 'span8'], ['Current Flock & Quantity', 'span10']]
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'flocks/movement_fields',
            headers: headers, with_type: with_type, text: 'Add Move'
  end

  def render_harvest_detail_fields builder, xies_name, with_type=true
    headers = [['House', 'span4'], ['Flock', 'span8'], ['Prod 1', 'span4'], ['Prod 2', 'span4'], ['Death', 'span4'], ['Note', 'span8']]
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'harvesting_slips/harvest_detail_fields',
            headers: headers, with_type: with_type, text: 'Add House'
  end

  def harvesting_slip_lock? slip
    if slip.try(:salary_note).try(:pay_slip)
      true
    else
      false
    end
  end
end