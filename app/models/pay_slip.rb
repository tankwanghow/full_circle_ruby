class PaySlip < ActiveRecord::Base
  belongs_to :employee
  belongs_to :pay_from, class_name: "Account", foreign_key: "pay_from_id"
  has_many :advances, order: :doc_date
  has_many :salary_notes, autosave: true, include: :salary_type, order: ["salary_types.name", :doc_date]
  has_many :transactions, as: :doc
  validates_presence_of :employee_name, :pay_from_name1, :pay_date, :doc_date

  before_save :build_transactions

  scope :employee, ->(emp_name) { joins(:employee).where("employees.name = ?", emp_name) }
  scope :month_year, ->(month, year) { where("date_part('month', pay_date) = ? and date_part('year', pay_date) = ?", month, year) }

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :amount,
             content: [:id, :employee_name, :pay_from_name1, :chq_no, :pay_date]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      pay_date: r.pay_date.to_s, 
      employee: r.employee_name,
      pay_from: r.pay_from_name1,
      chq_no: r.chq_no,
      salary_notes: r.salary_notes_audit_string,
      advances: r.advances_audit_string
    }
  end

  include ValidateTransactionsBalance

  include ValidateBelongsTo
  validate_belongs_to :employee, :name
  validate_belongs_to :pay_from, :name1

  include AuditString
  audit_string :advances, :salary_notes

  def calculate_pay
    SalaryCalculationService.calculate self
  end

  def advances_attributes= vals
    vals.each do |k, v|
      adv = advances.detect { |t| t.id == v['id'].to_i }
      if v.class == ActiveSupport::HashWithIndifferentAccess
        destroyed = ['1', 'true'].include?(v.delete('_destroy')) ? true :false
      end
      if !adv and !destroyed
        adv = Advance.where(id: v['id'].to_i, pay_slip_id: nil, employee_id: self.employee_id).first
        adv.pay_slip = self
        advances << adv
      elsif adv and destroyed
        adv.pay_slip = nil
        adv.save
        advances.delete_if { |t| t.id == adv.id }
      end
    end
  end

  def salary_notes_attributes= vals
    vals.delete_if { |k, v| v['quantity'].to_f == 0 and v['unit_price'].to_f == 0 }
    vals.each do |k,v|
      note = salary_notes.detect { |t| t.id == v['id'].to_i }
      if v.class == ActiveSupport::HashWithIndifferentAccess
        destroyed = ['1', 'true'].include?(v.delete('_destroy')) ? true :false
      end
      if note
        if !destroyed 
          note.attributes = v
        else
          if note.generated
            note.mark_for_destruction
          else
            note.pay_slip = nil
            note.save
            salary_notes.delete_if { |t| t.id == note.id }
          end
        end
      else
        if !destroyed
          note = SalaryNote.where(id: v['id'].to_i, pay_slip_id: nil, employee_id: self.employee_id).first if v['id']
          if note
            note.pay_slip = self
            salary_notes << note
          else
            v['employee_name'] = self.employee_name
            salary_notes.build v
          end
        else
          salary_notes.delete_if { |t| t.id == v['id'].to_i }
        end
      end
    end
  end

  def amount
    salary_notes.select { |t| t.salary_type.classifiaction == 'Addition' and !t.marked_for_destruction? }.
      inject(0) { |sum, t| sum + t.amount } -
    salary_notes.select { |t| t.salary_type.classifiaction == 'Deduction' and !t.marked_for_destruction? }.
      inject(0) { |sum, t| sum + t.amount } -
    advances.inject(0) { |sum, t| sum + t.amount }
  end

private

  def build_transactions
    transactions.destroy_all
    pay_from_transaction
    salary_payable_transaction
    validates_transactions_balance
  end

  def pay_from_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: pay_from,
      note: "Salary To #{employee_name}",
      amount: -amount,
      user: User.current
    )
  end

  def salary_payable_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: Account.find_by_name1('Salary Payable'),
      note: "From #{pay_from_name1} to #{employee_name}",
      amount: amount,
      user: User.current
    )
  end

end