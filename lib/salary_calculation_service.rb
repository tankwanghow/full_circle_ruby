class SalaryCalculationService

  def self.calculate payslip
    @payslip = payslip
    @payslip.salary_notes.select{ |t| !t.marked_for_destruction? and !t.salary_type.service_method.blank? }.each do |n|
      if respond_to?(n.salary_type.service_method)
        value = send(n.salary_type.service_method)
        n.quantity = value[0]
        n.unit_price = value[1]
      else
        n.quantity = -1
        n.unit_price = 99999999
      end
    end
  end

private

  def self.epf_employer
    [1, EpfContributionService.new(@payslip).epf_employer]
  end

  def self.epf_employee
    [1, EpfContributionService.new(@payslip).epf_employee]
  end

  def self.socso_employer
    [1, SocsoContributionService.new(@payslip).socso_employer]
  end

  def self.socso_employee
    [1, SocsoContributionService.new(@payslip).socso_employee]
  end

  def self.pcb_employee
    [1, PcbCalculationService.new(@payslip).pcb_current_month]
  end

end