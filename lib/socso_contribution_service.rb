class SocsoContributionService
  NON_SOCSOABLE_ADDITION_NAMES = [ 'Employee Bonus', 'Director Bonus' ]
  TABLE = [
            [   1,    30,   0.4,   0.1,  0.3],
            [  30,    50,   0.7,   0.2,  0.5],
            [  50,    70,   1.1,   0.3,  0.8],
            [  70,   100,   1.5,   0.4,  1.1],
            [ 100,   140,   2.1,   0.6,  1.5],
            [ 140,   200,  2.95,  0.85,  2.1],
            [ 200,   300,  4.35,  1.25,  3.1],
            [ 300,   400,  6.15,  1.75,  4.4],
            [ 400,   500,  7.85,  2.25,  5.6],
            [ 500,   600,  9.65,  2.75,  6.9],
            [ 600,   700, 11.35,  3.25,  8.1],
            [ 700,   800, 13.15,  3.75,  9.4],
            [ 800,   900, 14.85,  4.25, 10.6],
            [ 900,  1000, 16.65,  4.75, 11.9],
            [1000,  1100, 18.35,  5.25, 13.1],
            [1100,  1200, 20.15,  5.75, 14.4],
            [1200,  1300, 21.85,  6.25, 15.6],
            [1300,  1400, 23.65,  6.75, 16.9],
            [1400,  1500, 25.35,  7.25, 18.1],
            [1500,  1600, 27.15,  7.75, 19.4],
            [1600,  1700, 28.85,  8.25, 20.6],
            [1700,  1800, 30.65,  8.75, 21.9],
            [1800,  1900, 32.35,  9.25, 23.1],
            [1900,  2000, 34.15,  9.75, 24.4],
            [2000,  2100, 35.85, 10.25, 25.6],
            [2100,  2200, 37.65, 10.75, 26.9],
            [2200,  2300, 39.35, 11.25, 28.1],
            [2300,  2400, 41.15, 11.75, 29.4],
            [2400,  2500, 42.85, 12.25, 30.6],
            [2500,  2600, 44.65, 12.75, 31.9],
            [2600,  2700, 46.35, 13.25, 33.1],
            [2700,  2800, 48.15, 13.75, 34.4],
            [2800,  2900, 49.85, 14.25, 35.6],
            [2900,  3000, 51.65, 14.75, 36.9],
            [3000,  3100, 53.35, 15.25, 38.1],
            [3100,  3200, 55.15, 15.75, 39.4],
            [3200,  3300, 56.85, 16.25, 40.6],
            [3300,  3400, 58.65, 16.75, 41.9],
            [3400,  3500, 60.35, 17.25, 43.1],
            [3500,  3600, 62.15, 17.75, 44.4],
            [3600,  3700, 63.85, 18.25, 45.6],
            [3700,  3800, 65.65, 18.75, 46.9],
            [3800,  3900, 67.35, 19.25, 48.1],
            [3900,  4000, 69.05, 19.75, 49.4],
            [4000, 9**99, 69.05, 19.75, 49.4]
          ]

  def initialize payslip
    @payslip = payslip
  end

  def socso_employer
    pd = Date.parse("#{@payslip.pay_date}-#{@payslip.pay_date}-01")
    if @payslip.employee.age_at(pd) < 60
      grab_row_where_salary_between[2]
    else
      grab_row_where_salary_between[4]
    end
  end

  def socso_employee
    pd = Date.parse()"#{@payslip.pay_date}-#{@payslip.pay_date}-01")
    if @payslip.employee.age_at(pd) < 60
      grab_row_where_salary_between[3]
    else
      0
    end
  end

  def socso_employee_no_age
    grab_row_where_salary_between[3]
  end

  def socso_employer_no_age
    grab_row_where_salary_between[2]
  end

private

  def grab_row_where_salary_between
    TABLE.detect { |t| sum_additions.between?(t[0], t[1])} || [0,0,0,0,0]
  end

  def addition_notes
    @payslip.salary_notes.select do |t|
      !t.marked_for_destruction? and
      t.salary_type.classifiaction == 'Addition' and
      !NON_SOCSOABLE_ADDITION_NAMES.include?(t.salary_type.name)
    end
  end

  def sum_additions
    addition_notes.inject(0) { |sum, t| sum + t.amount }
  end

end
