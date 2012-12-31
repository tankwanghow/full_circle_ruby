class RecurringNote < ActiveRecord::Base
  belongs_to :salary_type
  belongs_to :employee
  has_many :salary_notes
  validates_presence_of :employee_name, :salary_type_name, :doc_date, :start_date, :status, :note
  validates_numericality_of :amount, greater_than: 0
  validates_numericality_of :target_amount

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :amount,
             content: [:id, :employee_name , :salary_type_name, :note, :amount,
                       :target_amount, :start_date, :end_date, :status]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      employee: r.employee_name,
      salary_type: r.salary_type_name,
      note: r.note,
      amount: r.amount.to_money.format,
      target_amount: r.target_amount.to_money.format,
      start_date: r.start_date,
      end_date: r.end_date,
      status: r.status
    }
  end

  include ValidateBelongsTo
  validate_belongs_to :employee, :name
  validate_belongs_to :salary_type, :name

  scope :active, -> { where(status: 'Active') }
  scope :employee, ->(emp_name) { joins(:employee).where('employees.name = ?', emp_name) }
  scope :targeted, -> { where('target_amount > 0') }
  scope :not_targeted, -> { where('target_amount = 0') }
  scope :notes_amount_lt_target_amount, 
        -> { joins('left outer join salary_notes on salary_notes.recurring_note_id = recurring_notes.id').
             group('recurring_notes.id').
             having('COALESCE(sum(salary_notes.quantity * salary_notes.unit_price), 0) < recurring_notes.target_amount') }
  scope :start_date_lte, ->(pay_date) { where('start_date <= ?', pay_date.to_date) }
  scope :end_date_gte, ->(pay_date) { where('end_date >= ?', pay_date.to_date) }
  scope :targeted_recurrable, 
        ->(emp_name, pay_date) { targeted.employee(emp_name).start_date_lte(pay_date).notes_amount_lt_target_amount }
  scope :not_targeted_recurrable_has_end_date, 
        ->(emp_name, pay_date) { not_targeted.employee(emp_name).start_date_lte(pay_date).end_date_gte(pay_date) }
  scope :not_targeted_recurrable_dont_has_end_date, 
        ->(emp_name, pay_date) { not_targeted.employee(emp_name).start_date_lte(pay_date).where(end_date: nil) }
end
