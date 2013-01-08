class PcbCalculationService
  EMPLOYEE_ZAKAT_NAME = 'Employee Zakat'
  EMPLOYEE_EPF_NAME = 'EPF By Employee'
  EMPLOYEE_PCB_NAME = 'Employee PCB'
  NON_RESIDENT_TAX_RATE = 0.26
  QUALIFY_CHILDREN_DEDUCTION = 1000.0
  INDIVIDUAL_DEDUCTION = 9000.0
  SPOUSE_DEDUCTION = 3000.0
  EPF_INSURANCE_DEDUCTION_LIMIT = 6000.0
  TAXABLE_INCOME_NAMES = [
    'Monthly Salary', 'Daily Salary', 'Hourly Salary', 'Director Salary',
    'Overtime Salary', 'Sunday Salary', 'Holiday Salary', 'Commission',
    'By Piece Works'
  ]
  SCHEDULE = [
               [  2500.01,   5000.0,   2500.0, 0.00,  -400.0,  -800.0],
               [  5000.01,  20000.0,   5000.0, 0.02,  -400.0,  -800.0],
               [ 20000.01,  35000.0,  20000.0, 0.06,  -100.0,  -500.0],
               [ 35000.01,  50000.0,  35000.0, 0.11,  1200.0,  1200.0],
               [ 50000.01,  70000.0,  50000.0, 0.19,  2850.0,  2850.0],
               [ 70000.01, 100000.0,  70000.0, 0.24,  6650.0,  6650.0],
               [100000.01, 999.0**9, 100000.0, 0.26, 13850.0, 13850.0]
             ]

  def initialize payslip
    @payslip = payslip
  end

  def pcb_current_month
    if !resident_employee?
      non_resident_pcb_current_month
    else
      resident_pcb_current_month
    end
  end

  def resident_employee?
    return true if @payslip.employee.nationality == 'Malaysian' || @payslip.employee.nationality == 'Malaysia'
    false
  end

  def resident_pcb_current_month
    pp = total_taxable_income_for_the_year
    m = amount_of_first_taxable_income
    r = tax_rate
    b = amount_of_tax_on_M_less_tax_rebate_self_and_spouse
    z = zakat_paid_for_the_year
    x = pcb_paid_current_year
    n = remaning_working_month_in_a_year
    cz = current_month_zakat
    pcb = nearest_five_cents((((((pp-m)*r)+b)-(z+x))/(n+1)) - cz)
    pcb < 0 ? 0 : pcb
  end

  def nearest_five_cents val
    truncate_val = (val * 100).to_i
    t = truncate_val % 5
    if t == 0  
      return (truncate_val/100).round 2
    else  
      return (truncate_val.round(2) + (5 - t)) / 100    
    end  
  end  

  def non_resident_pcb_current_month
    current_month_taxable_income * NON_RESIDENT_TAX_RATE
  end

  def pcb_paid_current_year
    SalaryNote.
      where(employee_id: @payslip.employee_id).
      where("date_part('year', doc_date) = ?", @payslip.pay_date.year).
      where("date_part('month', doc_date) < ?", @payslip.pay_date.month).
      where(salary_type_id: SalaryType.find_by_name(EMPLOYEE_PCB_NAME).id).
      sum("quantity * unit_price").to_f
  end

  def total_taxable_income_for_the_year
    ((current_year_taxable_income - current_year_epf) + 
     (current_month_taxable_income - current_month_epf) + 
     ((current_month_taxable_income - estimated_future_epf) * remaning_working_month_in_a_year)) -
    (INDIVIDUAL_DEDUCTION + spouse_deduction + children_deduction)
  end

  def current_year_epf
    year_epf = SalaryNote.
      where(employee_id: @payslip.employee_id).
      where("date_part('year', doc_date) = ?", @payslip.pay_date.year).
      where("date_part('month', doc_date) < ?", @payslip.pay_date.month).
      where(salary_type_id: SalaryType.find_by_name(EMPLOYEE_EPF_NAME).id).
      sum("quantity * unit_price").to_f
    return year_epf > EPF_INSURANCE_DEDUCTION_LIMIT ? EPF_INSURANCE_DEDUCTION_LIMIT : year_epf
  end

  def current_month_epf
    current = current_month_epf_notes.inject(0) { |sum, t| sum + t.amount }
    val = EPF_INSURANCE_DEDUCTION_LIMIT - current_year_epf - current
    if val >= 0
      return current
    else
      return current + val
    end
  end

  def estimated_future_epf
    k = current_year_epf
    k1 = current_month_epf
    kt = 0
    n = remaning_working_month_in_a_year
    return 0 if n == 0
    val = (EPF_INSURANCE_DEDUCTION_LIMIT - (k+k1+kt))/n
    val > k1 ? k1 : val
    val > 0 ? val : 0
  end

  def current_month_epf_notes
    @payslip.salary_notes.select do |t| 
      !t.marked_for_destruction? and 
      t.salary_type.name == EMPLOYEE_EPF_NAME
    end
  end


  def amount_of_first_taxable_income
    row = SCHEDULE.detect { |t| total_taxable_income_for_the_year.to_f.between?(t[0], t[1]) }
    return row[2] if row
    0
  end

  def zakat_paid_for_the_year
    SalaryNote.
      where(employee_id: @payslip.employee_id).
      where("date_part('year', doc_date) = ?", @payslip.pay_date.year).
      where("date_part('month', doc_date) < ?", @payslip.pay_date.month).
      where(salary_type_id: SalaryType.find_by_name(EMPLOYEE_ZAKAT_NAME).id).
      sum("quantity * unit_price").to_f
  end

  def current_month_zakat_notes
    @payslip.salary_notes.select do |t| 
      !t.marked_for_destruction? and 
      t.salary_type.name == EMPLOYEE_ZAKAT_NAME
    end
  end

  def current_month_zakat
    current_month_zakat_notes.inject(0) { |sum, t| sum + t.amount }
  end

  def amount_of_tax_on_M_less_tax_rebate_self_and_spouse
    row = SCHEDULE.detect { |t| total_taxable_income_for_the_year.between?(t[0], t[1]) }
    return row[employee_pcb_category] if row
    0
  end

  def employee_pcb_category
    if !@payslip.employee.married?
      return 4
    elsif @payslip.employee.married? and @payslip.employee.partner_working
      return 4
    elsif @payslip.employee.married? and !@payslip.employee.partner_working
      return 5
    end
  end

  def tax_rate
    row = SCHEDULE.detect { |t| total_taxable_income_for_the_year.between?(t[0], t[1]) }
    return row[3] if row
    0
  end

  def spouse_deduction
    if @payslip.employee.married?
      return SPOUSE_DEDUCTION if !@payslip.employee.partner_working
    end
    return 0
  end

  def children_deduction
    return @payslip.employee.children * QUALIFY_CHILDREN_DEDUCTION
  end

  def current_month_taxable_income_notes
    @payslip.salary_notes.select do |t| 
      !t.marked_for_destruction? and 
      t.salary_type.classifiaction == 'Addition' and
      TAXABLE_INCOME_NAMES.include?(t.salary_type.name)
    end
  end

  def current_month_taxable_income
    current_month_taxable_income_notes.inject(0) { |sum, t| sum + t.amount }
  end

  def current_year_taxable_income_notes
    SalaryNote.where(employee_id: @payslip.employee_id).
      where("date_part('year', doc_date) = ?", @payslip.pay_date.year).
      where("date_part('month', doc_date) < ?", @payslip.pay_date.month).
      where(salary_type_id: SalaryType.where(name: TAXABLE_INCOME_NAMES))
  end

  def current_year_taxable_income
    current_year_taxable_income_notes.inject(0) { |sum, t| sum + t.amount }
  end

  def remaning_working_month_in_a_year
    12.0 - @payslip.pay_date.month
  end

end