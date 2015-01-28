module EmployeesHelper
   def render_salary_types_fields builder, xies_name
    render 'share/nested_fields', f: builder, xies_name: xies_name, field: 'employees/salary_type_fields',
            headers: [['Name', 'span10'], ['Amount', 'span6']],
            text: 'Add Type'
  end
end