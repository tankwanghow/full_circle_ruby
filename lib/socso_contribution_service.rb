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
            [ 300,   400,  6.15,  1.75,  4.3],
            [ 400,   500,  7.85,  2.25,  5.6],
            [ 500,   600,  9.65,  2.75,  6.8],
            [ 600,   700, 11.35,  3.25,  8.1],
            [ 700,   800, 13.15,  3.75,  9.3],
            [ 800,   900, 14.85,  4.25, 10.6],
            [ 900,  1000, 16.65,  4.75, 11.8],
            [1000,  1100, 18.35,  5.25, 13.1],
            [1100,  1200, 20.15,  5.75, 14.3],
            [1200,  1300, 21.85,  6.25, 15.6],
            [1300,  1400, 23.65,  6.75, 16.8],
            [1400,  1500, 25.35,  7.25, 18.1],
            [1500,  1600, 27.15,  7.75, 19.3],
            [1600,  1700, 28.85,  8.25, 20.6],
            [1700,  1800, 30.65,  8.75, 21.8],
            [1800,  1900, 32.35,  9.25, 23.1],
            [1900,  2000, 34.15,  9.75, 24.3],
            [2000,  2100, 35.85, 10.25, 25.6],
            [2100,  2200, 37.65, 10.75, 26.8],
            [2200,  2300, 39.35, 11.25, 28.1],
            [2300,  2400, 41.15, 11.75, 29.3],
            [2400,  2500, 42.85, 12.25, 30.6],
            [2500,  2600, 44.65, 12.75, 31.8],
            [2600,  2700, 46.35, 13.25, 33.1],
            [2700,  2800, 48.15, 13.75, 34.4],
            [2800,  2900, 49.85, 14.25, 35.6],
            [2900, 99**9, 51.65, 14.75, 36.9]
          ]

  def initialize payslip
    @payslip = payslip
  end

  def socso_employer
    if @payslip.employee.age_at(@payslip.pay_date) <= 55
      grab_row_where_salary_between[2]
    else
      grab_row_where_salary_between[4]
    end
  end

  def socso_employee
    if @payslip.employee.age_at(@payslip.pay_date) <= 55
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
      !NON_SOCSOABLE_ADDITION_NAMES.include?(t.salary_type.name)
    end
  end

  def sum_additions
    addition_notes.inject(0) { |sum, t| sum + t.amount }
  end

end