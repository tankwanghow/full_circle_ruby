class EpfContributionService

  EPFABLE_ADDITION_NAMES = [
    'Monthly Salary', 'Daily Salary', 'Hourly Salary', 'Director Salary',
    'Overtime Salary', 'Sunday Salary', 'Holiday Salary', 'Commission',
    'By Piece Works'
  ]

  def initialize payslip
    @payslip = payslip
  end

  def epf_employer
    return 0 if sum_additions <= 10
    emp_age = (Date.today - @payslip.employee.birth_date).to_i/365.0
    if sum_additions > 5000
      rate = emp_age > 55 ? 0.06 : 0.12
    else
      rate = emp_age > 55 ? 0.065 : 0.13
    end
    (epf_calculation_mod_salary * rate).ceil
  end

  def epf_employee
    return 0 if sum_additions <= 10
    rate = @payslip.employee.age_at(@payslip.pay_date) > 55 ? 0.055 : 0.11
    (epf_calculation_mod_salary * rate).ceil
  end

private

  def epf_calculation_mod_salary
    mod = sum_additions % 20
    mod > 0 ? (sum_additions - mod + 20) : sum_additions
  end

  def addition_notes
    @payslip.salary_notes.select do |t| 
      !t.marked_for_destruction? and 
      t.salary_type.classifiaction == 'Addition' #and
      #EPFABLE_ADDITION_NAMES.include?(t.salary_type.name)
    end
  end

  def sum_additions
    addition_notes.inject(0) { |sum, t| sum + t.amount }
  end

end