class EmployeeSalaryType < ActiveRecord::Base
  belongs_to :employee
  belongs_to :salary_type
  validates_numericality_of :amount
  validates_presence_of :salary_type_name

  include ValidateBelongsTo
  validate_belongs_to :employee, :name
  validate_belongs_to :salary_type, :name

  scope :addition, -> { joins(:salary_type).where("salary_types.classifiaction = ?", 'Addition') }
  scope :deduction, -> { joins(:salary_type).where("salary_types.classifiaction = ?", 'Deduction') }
  scope :contribution, -> { joins(:salary_type).where("salary_types.classifiaction = ?", 'Contribution') }

  def simple_audit_string
    [ salary_type.name, amount.to_money.format ].join ' '
  end 
end