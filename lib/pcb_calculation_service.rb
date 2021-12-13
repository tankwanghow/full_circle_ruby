class PcbCalculationService
  EMPLOYEE_ZAKAT_NAME = 'Employee Zakat'
  EMPLOYEE_EPF_NAME= 'EPF By Employee'
  EMPLOYEE_PCB_NAME = 'Employee PCB'
  NON_RESIDENT_TAX_RATE = 0.26
  QUALIFY_CHILDREN_DEDUCTION = 2000.0
  INDIVIDUAL_DEDUCTION = 9000.0
  SPOUSE_DEDUCTION = 4000.0
  EPF_INSURANCE_DEDUCTION_LIMIT = 4000.0
  NON_TAXABLE_INCOME_NAMES = [ ]
  ADDITION_TAXABLE_INCOME_NAMES = [ 'Employee Bonus', 'Director Bonus' ]
  SCHEDULE = [
               [  5000.01,   20000.0,   5000.0,  0.01,   -400.0,   -800.0],
               [ 20000.01,   35000.0,  20000.0,  0.03,   -250.0,   -650.0],
               [ 35000.01,   50000.0,  35000.0,  0.08,    600.0,    600.0],
               [ 50000.01,   70000.0,  50000.0,  0.14,   1800.0,   1800.0],
               [ 70000.01,  100000.0,  70000.0,  0.21,   4600.0,   4600.0],
               [100000.01,  250000.0, 100000.0,  0.24,  10900.0,  10900.0],
               [250000.01,  400000.0, 250000.0, 0.245,  46900.0,  46900.0],
               [400000.01,  600000.0, 400000.0,  0.25,  83650.0,  83650.0],
               [600000.01, 1000000.0, 600000.0,  0.26, 133650.0, 133650.0]
             ]

  def initialize payslip
    @payslip = payslip
    @emp = payslip.employee
    @pay_date = payslip.pay_date
  end

  def pcb_current_month
    if !resident_employee?
      non_resident_pcb_current_month
    else
      pcb = nearest_five_cents(resident_pcb_current_month + resident_addition_pcb)
    end
    pcb > 0 ? pcb : 0
  end

  def resident_employee?
    return true if @payslip.employee.nationality == 'Malaysian' || @payslip.employee.nationality == 'Malaysia'
    false
  end

  def non_resident_pcb_current_month
    current_month_taxable_income * NON_RESIDENT_TAX_RATE
  end

  def remaning_working_month_in_a_year
    12.0 - @payslip.pay_date.month
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

  def amount_of_first_taxable_income
    row = SCHEDULE.detect { |t| total_taxable_income_for_the_year.to_f.between?(t[0], t[1]) }
    return row[2] if row
    0
  end

  def resident_pcb_current_month
    y  = current_year_taxable_income
    y1 = current_month_taxable_income
    y2 = estimated_future_taxable_income
    k  = current_year_epf
    k1 = current_month_epf
    k2 = estimated_future_epf
    n  = remaning_working_month_in_a_year
    d  = INDIVIDUAL_DEDUCTION
    s  = spouse_deduction
    q  = QUALIFY_CHILDREN_DEDUCTION
    c  = @payslip.employee.children
    p  = (y - k) + (y1 - k1) + ((y2 - k2)*n) - d - s - (q * c)
    m  = SCHEDULE.detect { |t| p.between?(t[0], t[1]) }[2]
    r  = SCHEDULE.detect { |t| p.between?(t[0], t[1]) }[3]
    b  = SCHEDULE.detect { |t| p.between?(t[0], t[1]) }[employee_pcb_category]
    x  = pcb_paid_current_year
    z  = current_month_zakat + zakat_paid_for_the_year
    mtd = ((((p - m)*r) + b) - (z + x)) / (n + 1)
  end

  def resident_addition_pcb
    if addition_taxable_income > 0
      y  = current_year_taxable_income
      y1 = current_month_taxable_income
      y2 = estimated_future_taxable_income
      yt = addition_taxable_income
      k  = current_year_epf
      k1 = current_month_epf
      k2 = estimated_future_epf
      kt = 0
      n  = remaning_working_month_in_a_year
      d  = INDIVIDUAL_DEDUCTION
      s  = spouse_deduction
      q  = QUALIFY_CHILDREN_DEDUCTION
      c  = @payslip.employee.children
      p  = (y - k) + (y1 - k1) + ((y2 - k2)*n) + (yt - kt) - d - s - (q * c)
      m  = SCHEDULE.detect { |t| p.between?(t[0], t[1]) } [2]
      r  = SCHEDULE.detect { |t| p.between?(t[0], t[1]) }[3]
      b  = SCHEDULE.detect { |t| p.between?(t[0], t[1]) }[employee_pcb_category]
      z  = current_month_zakat + zakat_paid_for_the_year
      x  = pcb_paid_current_year + (resident_pcb_current_month * (n+1))
      md = ((((p - m)*r) + b) - (z + x))
    else
      0
    end
  end

  def pcb_paid_current_year
    SalaryNote.
      where(employee_id: @payslip.employee_id).
      where("date_part('year', doc_date) = ?", @payslip.pay_date.year).
      where("date_part('month', doc_date) < ?", @payslip.pay_date.month).
      where(salary_type_id: SalaryType.find_by_name(EMPLOYEE_PCB_NAME).id).
      sum("quantity * unit_price").to_f
  end

  def estimated_future_taxable_income
    current_month_taxable_income
  end

  def current_month_taxable_income
    @payslip.salary_notes.select do |t|
      !t.marked_for_destruction? and
      t.salary_type.classifiaction == 'Addition' and
      !NON_TAXABLE_INCOME_NAMES.include?(t.salary_type.name) and
      !ADDITION_TAXABLE_INCOME_NAMES.include?(t.salary_type.name)
    end.inject(0) { |sum, t| sum + t.amount }
  end

  def current_year_taxable_income
    SalaryNote.where(employee_id: @payslip.employee_id).
      where("date_part('year', doc_date) = ?", @payslip.pay_date.year).
      where("date_part('month', doc_date) < ?", @payslip.pay_date.month).
      where(salary_type_id: SalaryType.where(classifiaction: 'Addition')).
        inject(0) { |sum, t| sum + t.amount }
  end

  def current_month_epf
    cur_epf = @payslip.salary_notes.select do |t|
                !t.marked_for_destruction? and
                t.salary_type.name == EMPLOYEE_EPF_NAME
              end.inject(0) { |sum, t| sum + t.amount }
    if cur_epf == 0
      cur_epf = EpfContributionService.new(@payslip).epf_employee
    end
    (cur_epf + current_year_epf) <= EPF_INSURANCE_DEDUCTION_LIMIT ? cur_epf : 0
  end

  def current_year_epf
    year_epf = SalaryNote.
      where(employee_id: @emp.id).
      where("date_part('year', doc_date) = ?", @pay_date.year).
      where("date_part('month', doc_date) < ?", @pay_date.month).
      where(salary_type_id: SalaryType.find_by_name(EMPLOYEE_EPF_NAME).id).
      sum("quantity * unit_price")
    BigDecimal.new(year_epf) >= EPF_INSURANCE_DEDUCTION_LIMIT ? EPF_INSURANCE_DEDUCTION_LIMIT : BigDecimal.new(year_epf)
  end

  def estimated_future_epf
    val = (EPF_INSURANCE_DEDUCTION_LIMIT - current_month_epf - current_year_epf)/remaning_working_month_in_a_year
    k2 = val >= EPF_INSURANCE_DEDUCTION_LIMIT ? current_year_epf : val
    if current_month_epf + current_year_epf + (k2 * remaning_working_month_in_a_year) <= EPF_INSURANCE_DEDUCTION_LIMIT
      k2
    else
      0
    end
  end

  def addition_taxable_income
    @payslip.salary_notes.select do |t|
      !t.marked_for_destruction? and
      t.salary_type.classifiaction == 'Addition' and
      ADDITION_TAXABLE_INCOME_NAMES.include?(t.salary_type.name)
    end.inject(0) { |sum, t| sum + t.amount }
  end

  def zakat_paid_for_the_year
    SalaryNote.
      where(employee_id: @payslip.employee_id).
      where("date_part('year', doc_date) = ?", @payslip.pay_date.year).
      where("date_part('month', doc_date) < ?", @payslip.pay_date.month).
      where(salary_type_id: SalaryType.find_by_name(EMPLOYEE_ZAKAT_NAME).id).
      sum("quantity * unit_price").to_f
  end

  def current_month_zakat
    @payslip.salary_notes.select do |t|
      !t.marked_for_destruction? and
      t.salary_type.name == EMPLOYEE_ZAKAT_NAME
    end.inject(0) { |sum, t| sum + t.amount }
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

  def spouse_deduction
    if @payslip.employee.married?
      return SPOUSE_DEDUCTION if !@payslip.employee.partner_working
    end
    return 0
  end

end
