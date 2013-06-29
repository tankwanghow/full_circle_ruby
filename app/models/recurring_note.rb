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

  scope :should_recur, ->(pay_date) { where('start_date <= ?', pay_date).should_not_end_recurring(pay_date) }
  scope :should_not_end_recurring, ->(pay_date) { where('end_date <= ? or end_date is null', pay_date) }
  scope :employee, ->(id) { joins(:employee).where('employees.id = ?', id) }
  scope :no_target, -> { where('target_amount = 0') }
  scope :target_not_reach, 
        ->{ select('recurring_notes.*, COALESCE(sum(salary_notes.quantity * salary_notes.unit_price), 0) as cumed').
            joins('left outer join salary_notes on salary_notes.recurring_note_id = recurring_notes.id').
            group('recurring_notes.id').
            having('COALESCE(sum(salary_notes.quantity * salary_notes.unit_price), 0) < recurring_notes.target_amount') }
  scope :active_with_target_not_reach, 
        ->(emp_id, pay_date) { employee(emp_id).should_recur(pay_date).target_not_reach.where(status: 'Active') }
  scope :active_with_no_target, 
        ->(emp_id, pay_date) { employee(emp_id).should_recur(pay_date).no_target.where(status: 'Active') }


  def self.fill_note_for payslip
    active_with_no_target(payslip.employee, payslip.pay_date).each do |t|
      payslip.salary_notes.build(employee: t.employee, doc_date: payslip.pay_date, salary_type: t.salary_type, quantity: 1, unit: "-", unit_price: t.amount, recurring_note: t, generated: true, note: t.note)
    end
    active_with_target_not_reach(payslip.employee, payslip.pay_date).each do |t|
      if t.amount + BigDecimal.new(t.cumed) > t.target_amount
        amt = t.target_amount - BigDecimal.new(t.cumed)
      else
        amt = t.amount
      end
      payslip.salary_notes.build(employee: t.employee, doc_date: payslip.pay_date, salary_type: t.salary_type, quantity: 1, unit: "-", unit_price: amt, recurring_note: t, generated: true, note: t.note)
    end
  end
end
