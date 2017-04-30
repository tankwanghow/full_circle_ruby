class SalaryCalculationService

  def self.calculate payslip
    @payslip = payslip
    @payslip.salary_notes.select{ |t| !t.marked_for_destruction? and !t.salary_type.service_method.blank? }.each do |n|
      if service_respond_to?(n.salary_type)
        value = call_service_method(n.salary_type)
        n.quantity = value[0]
        n.unit_price = value[1]
      else
        n.quantity = -1
        n.unit_price = 99999999
      end
    end
  end

private

  def self.service_respond_to? salary_type
    salary_type.service_class.constantize.instance_method_names.include?(salary_type.service_method)
  end

  def self.call_service_method salary_type
    [1, salary_type.service_class.constantize.new(@payslip).send(salary_type.service_method)]
  end

end
