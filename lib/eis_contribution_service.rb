class EisContributionService
  NON_EISABLE_ADDITION_NAMES = [ 'Employee Bonus', 'Director Bonus' ]
  TABLE = [
    [   0,   30, 0.05, 0.05, 0.10],
    [  30,   50, 0.10, 0.10, 0.20],
    [  50,   70, 0.15, 0.15, 0.30],
    [  70,  100, 0.20, 0.20, 0.40],
    [ 100,  140, 0.25, 0.25, 0.50],
    [ 140,  200, 0.35, 0.35, 0.70],
    [ 200,  300, 0.50, 0.50, 1.00],
    [ 300,  400, 0.70, 0.70, 1.40],
    [ 400,  500, 0.90, 0.90, 1.80],
    [ 500,  600, 1.10, 1.10, 2.20],
    [ 600,  700, 1.30, 1.30, 2.60],
    [ 700,  800, 1.50, 1.50, 3.00],
    [ 800,  900, 1.70, 1.70, 3.40],
    [ 900, 1000, 1.90, 1.90, 3.80],
    [1000, 1100, 2.10, 2.10, 4.20],
    [1100, 1200, 2.30, 2.30, 4.60],
    [1200, 1300, 2.50, 2.50, 5.00],
    [1300, 1400, 2.70, 2.70, 5.40],
    [1400, 1500, 2.90, 2.90, 5.80],
    [1500, 1600, 3.10, 3.10, 6.20],
    [1600, 1700, 3.30, 3.30, 6.60],
    [1700, 1800, 3.50, 3.50, 7.00],
    [1800, 1900, 3.70, 3.70, 7.40],
    [1900, 2000, 3.90, 3.90, 7.80],
    [2000, 2100, 4.10, 4.10, 8.20],
    [2100, 2200, 4.30, 4.30, 8.60],
    [2200, 2300, 4.50, 4.50, 9.00],
    [2300, 2400, 4.70, 4.70, 9.40],
    [2400, 2500, 4.90, 4.90, 9.80],
    [2500, 2600, 5.10, 5.10, 10.20],
    [2600, 2700, 5.30, 5.30, 10.60],
    [2700, 2800, 5.50, 5.50, 11.00],
    [2800, 2900, 5.70, 5.70, 11.40],
    [2900, 3000, 5.90, 5.90, 11.80],
    [3000, 3100, 6.10, 6.10, 12.20],
    [3100, 3200, 6.30, 6.30, 12.60],
    [3200, 3300, 6.50, 6.50, 13.00],
    [3300, 3400, 6.70, 6.70, 13.40],
    [3400, 3500, 6.90, 6.90, 13.80],
    [3500, 3600, 7.10, 7.10, 14.20],
    [3600, 3700, 7.30, 7.30, 14.60],
    [3700, 3800, 7.50, 7.50, 15.00],
    [3800, 3900, 7.70, 7.70, 15.40],
    [3900, 9**9, 7.90, 7.90, 15.80]
  ]

  def initialize payslip
    @payslip = payslip
  end

  def eis_employer
    pd = Date.parse("#{@payslip.pay_date}-#{@payslip.pay_date}-01")
    if @payslip.employee.age_at(pd) < 60
      grab_row_where_salary_between[2]
    else
      0
    end
  end

  def eis_employee
    pd = Date.parse("#{@payslip.pay_date}-#{@payslip.pay_date}-01")
    if @payslip.employee.age_at(pd) < 60
      grab_row_where_salary_between[3]
    else
      0
    end
  end

private

  def grab_row_where_salary_between
    TABLE.detect { |t| sum_additions.between?(t[0], t[1])} || [0,0,0,0,0]
  end

  def addition_notes
    @payslip.salary_notes.select do |t|
      !t.marked_for_destruction? and
      t.salary_type.classifiaction == 'Addition' and
      !NON_EISABLE_ADDITION_NAMES.include?(t.salary_type.name)
    end
  end

  def sum_additions
    addition_notes.inject(0) { |sum, t| sum + t.amount }
  end

end
