class Advance < ActiveRecord::Base
  belongs_to :pay_from, class_name: "Account", foreign_key: "pay_from_id"
  belongs_to :employee
  belongs_to :pay_slip
  has_many :transactions, as: :doc
  validates_presence_of :pay_from_name1, :doc_date, :employee_name
  validates_numericality_of :amount, greater_than: 0

  before_save :build_transactions

  include ValidateTransactionsBalance

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :amount,
             content: [:id, :employee_name, :pay_from_name1, :chq_no]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      employee: r.employee_name,
      amount: r.amount.to_money.format,
      pay_from: r.pay_from_name1,
      chq_no: r.chq_no
    }
  end

  include ValidateBelongsTo
  validate_belongs_to :employee, :name
  validate_belongs_to :pay_from, :name1

private

  def build_transactions
    transactions.destroy_all
    salary_payable_transaction
    pay_from_transaction
    validates_transactions_balance
  end

  def pay_from_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: pay_from,
      note: 'Salary Advance To ' + employee_name,
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
