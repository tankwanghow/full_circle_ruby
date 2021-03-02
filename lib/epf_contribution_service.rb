class EpfContributionService

  NON_EPFABLE_ADDITION_NAMES = ['Employee Bonus', 'Director Bonus']

  def initialize payslip
    @payslip = payslip
  end

  def epf_employer
    return 0 if sum_additions <= 10
    emp_age = @payslip.employee.age_at(@payslip.pay_date)
    if sum_additions > 5000
      rate = emp_age > 60 ? 0.04 : 0.12
    else
      rate = emp_age > 60 ? 0.04 : 0.13
    end
    (epf_calculation_mod_salary * rate).ceil
  end

  def epf_employee
    return 0 if sum_additions <= 10
    rate = @payslip.employee.age_at(@payslip.pay_date) > 60 ? 0 : 0.09
    (epf_calculation_mod_salary * rate).ceil
  end

private

  def epf_calculation_mod_salary
    mod_value = sum_additions > 5000 ? 100 : 20
    mod = sum_additions % mod_value
    mod > 0 ? (sum_additions - mod + mod_value) : sum_additions
  end

  def addition_notes
    @payslip.salary_notes.select do |t|
      !t.marked_for_destruction? and
      t.salary_type.classifiaction == 'Addition' and
      !NON_EPFABLE_ADDITION_NAMES.include?(t.salary_type.name)
    end
  end

  def sum_additions
    addition_notes.inject(0) { |sum, t| sum + t.amount }
  end

end
