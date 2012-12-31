class PaySlipGenerationService
  attr_accessor :employee_name, :pay_date

  # def initialize
  # end

  def generate
    @payslip = PaySlip.new employee_name: emp_name, pay_date: pay_date.to_date
    fill_in_payable_salary
    @payslip
  end

private

  def fill_in_payable_salary
    generate_nested_attributes_from_existing_notes(Advance, @payslip.advances)
    generate_nested_attributes_from_existing_notes(SalaryNote, @payslip.salary_notes)
    generate_nested_attributes_from_recurring_note
    generate_nested_attributes_from_employee_salary_type
    reject_dupcilate_salary_type_with_zero_amount
  end

  def reject_dupcilate_salary_type_with_zero_amount
    kept = @payslip.salary_notes.select { |t| t.amount > 0 }
    zero = @payslip.salary_notes.select { |t| t.amount == 0 }
    @payslip.salary_notes = kept.concat(zero.select { |t| !kept.map { |k| k.salary_type_id }.include? t.salary_type_id })
  end

  def generate_nested_attributes_from_existing_notes klass, attributes
    klass.unpaid.smaller_eq(@pay_date).employee(@emp_name).each do |t|
      attributes << t
    end
  end

  def generate_nested_attributes_from_employee_salary_type
    Employee.find_by_name(@emp_name).salary_types.each do |t|
      @payslip.salary_notes.build(employee: t.employee, doc_date: @pay_date, salary_type: t.salary_type, quantity: 1, unit: "-", unit_price: t.amount)
    end
  end

  def generate_nested_attributes_from_recurring_note
    RecurringNote.targeted_recurrable(@emp_name, @pay_date).each do |t|
      @payslip.salary_notes.build(employee: t.employee, doc_date: @pay_date, salary_type: t.salary_type, quantity: 1, unit: "-", unit_price: t.amount, recurring_note: t)
    end
    RecurringNote.not_targeted_recurrable_has_end_date(@emp_name, @pay_date).each do |t|
      @payslip.salary_notes.build(employee: t.employee, doc_date: @pay_date, salary_type: t.salary_type, quantity: 1, unit: "-", unit_price: t.amount, recurring_note: t)
    end
    RecurringNote.not_targeted_recurrable_dont_has_end_date(@emp_name, @pay_date).each do |t|
      @payslip.salary_notes.build(employee: t.employee, doc_date: @pay_date, salary_type: t.salary_type, quantity: 1, unit: "-", unit_price: t.amount, recurring_note: t)
    end
  end

end