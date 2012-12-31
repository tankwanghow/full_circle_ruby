class PaySlip < ActiveRecord::Base
  belongs_to :employee
  belongs_to :pay_from, class_name: "Account", foreign_key: "pay_from_id"
  has_many :advances
  has_many :salary_notes
  has_many :transactions, as: :doc

  before_save :build_transactions

  accepts_nested_attributes_for :advances, allow_destroy: true, reject_if: :dont_process
  accepts_nested_attributes_for :salary_notes, allow_destroy: true, reject_if: :dont_process

  include Searchable
  searchable doc_date: :doc_date, #doc_amount: :amount,
             content: [:id, :employee_name, :pay_from_name1, :chq_no, :pay_date]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      pay_date: r.pay_date.to_s, 
      employee: r.employee_name,
      pay_from: r.pay_from_name1,
      chq_no: r.chq_no
    }
  end

  include ValidateTransactionsBalance

  include ValidateBelongsTo
  validate_belongs_to :employee, :name
  validate_belongs_to :pay_from, :name1

  include AuditString
  audit_string :advances, :salary_types

  def self.new_for emp_name, pay_date
    PaySlipGenerationService.new(emp_name, pay_date).generate
  end

  def calculate_pay
    SalaryCalculationService.calculate self
  end

private

  def dont_process
    return true if attr["id"].blank? && attr["amount"].to_f == 0
  end

  def build_transactions
    transactions.destroy_all

    validates_transactions_balance
  end

end