class SalaryCalculationService

  def self.calculate payslip
    @payslip = payslip
    payslip.salary_notes.select{ |t| !t.marked_for_destruction? and t.amount == 0 }.each do |n|
      n.quantity = 1
      n.unit_price = send(n.salary_type.service_method) if respond_to?(n.salary_type.service_method)
    end
  end

private

  def self.epf_employer
    EpfContributionService.new(@payslip).epf_employer
  end

  def self.epf_employee
    EpfContributionService.new(@payslip).epf_employee
  end  

  def self.socso_employer
    SocsoContributionService.new(@payslip).socso_employer
  end

  def self.socso_employee
    SocsoContributionService.new(@payslip).socso_employee
  end

  def self.pcb_employee
    PcbCalculationService.new(@payslip).pcb_current_month
  end

end