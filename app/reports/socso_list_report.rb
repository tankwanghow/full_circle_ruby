class SocsoListReport < Dossier::Report

  def sql
    <<-SQL
      select emp.name, id_no, socso_no,
             (select quantity * unit_price 
                from salary_notes sn
               inner join salary_types st on sn.salary_type_id = st.id
               where st.name = 'SOCSO By Employee'
                 and sn.pay_slip_id = ps.id) as employee_socso,
             (select quantity * unit_price 
                from salary_notes sn
               inner join salary_types st on sn.salary_type_id = st.id
               where st.name = 'SOCSO By Employer'
                 and sn.pay_slip_id = ps.id) as employer_socso
        from pay_slips ps
       inner join employees emp on emp.id = ps.employee_id
       where ps.pay_date >= :start_date
         and ps.pay_date <= :end_date
         and emp.nationality ilike '%malay%'
    SQL
  end

  def param_fields form
    form.input_field(:start_date, class: 'datepicker span5', placeholder: 'start date...') + 
    form.input_field(:end_date, class: 'datepicker span5', placeholder: 'end date...')
  end

  def start_date
    @options[:start_date] ? @options[:start_date].to_date : nil
  end

  def end_date
    @options[:end_date] ? @options[:end_date].to_date : nil
  end
  
end