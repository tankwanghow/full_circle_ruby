class PaySlipGenerationService
  attr_accessor :employee_name, :pay_date

  def initialize employee_name=nil, pay_date=nil
    @employee_name = employee_name
    @pay_date = pay_date
  end

  def generate_pay_slip
    @payslip = PaySlip.new employee_name: @employee_name, pay_date: @pay_date, doc_date: Date.today, pay_from_name1: 'Cash In Hand'
    fill_in_payable_salary
    @payslip
  end

  def regenerate_pay_slip id
    @payslip = PaySlip.find id
    fill_in_payable_salary
    @payslip.pay_date = @pay_date
    @payslip
  end

private

  def fill_in_payable_salary
    @payslip.advances_attributes = generate_nested_attributes_from_existing_notes(Advance)
    @payslip.salary_notes_attributes = generate_nested_attributes_from_existing_notes(SalaryNote)
    generate_nested_attributes_from_recurring_note
    generate_nested_attributes_from_employee_salary_type
    reject_dupcilate_salary_type_with_zero_amount
  end

  def reject_dupcilate_salary_type_with_zero_amount
    kept = @payslip.salary_notes.select { |t| t.amount > 0 }
    zero = @payslip.salary_notes.select { |t| t.amount == 0 }
    @payslip.salary_notes = kept.concat(zero.select { |t| !kept.map { |k| k.salary_type_id }.include? t.salary_type_id })
  end

  def generate_nested_attributes_from_existing_notes klass
    hash = {}
    klass.unpaid.smaller_eq(@pay_date).employee(@employee_name).each do |t|
      hash.merge!(t.id => t)
    end
    hash
  end

  def generate_nested_attributes_from_employee_salary_type
    Employee.find_by_name(@employee_name).salary_types.each do |t|
      @payslip.salary_notes.build(employee: t.employee, doc_date: @pay_date, salary_type: t.salary_type, quantity: 1, unit: "-", unit_price: t.amount, generated: true)
    end
  end

  def generate_nested_attributes_from_recurring_note
    RecurringNote.fill_note_for @payslip
  end

end
