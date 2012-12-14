class SalaryNote < ActiveRecord::Base
  belongs_to :salary_type
  belongs_to :employee
  belongs_to :pay_slip
  belongs_to :recurring_note
  has_many :transactions, as: :doc
  validates_presence_of :employee_name, :salary_type_name, :doc_date
  validates_numericality_of :quantity, :unit_price, greater_than: 0
  before_save :build_transactions

  include ValidateTransactionsBalance

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :amount,
             content: [:id, :employee_name , :salary_type_name, :note, :quantity,
                       :unit, :pay_slip_id, :recurring_note_id]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      employee: r.employee_name,
      salary_type: r.salary_type_name,
      note: r.note,
      quantity: r.quantity,
      unit: r.unit,
      amount: r.unit_price.to_money.format,
      pay_slip: r.pay_slip_id,
      recurring_note: r.recurring_note_id
    }
  end

  include ValidateBelongsTo
  validate_belongs_to :employee, :name
  validate_belongs_to :salary_type, :name

  def amount
    quantity * unit_price
  end

  def pay_slip_id
    pay_slip ? pay_slip.id : nil
  end

  def recurring_note_id
    recurring_note ? recurring_note.id : nil
  end

private

  def build_transactions
    transactions.destroy_all
    db_transaction
    cr_transaction
    validates_transactions_balance
  end

  def db_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: salary_type.db_account,
      note: "#{salary_type_name} #{note} #{employee_name}",
      amount: amount,
      user: User.current
    )
  end

  def cr_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: salary_type.cr_account,
      note: "#{salary_type_name} #{note} #{employee_name}",
      amount: -amount,
      user: User.current
    )
  end
end
