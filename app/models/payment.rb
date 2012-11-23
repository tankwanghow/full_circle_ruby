class Payment < ActiveRecord::Base
  belongs_to :pay_to, class_name: "Account", foreign_key: "pay_to_id"
  belongs_to :pay_from, class_name: "Account", foreign_key: "pay_from_id"
  has_many :pay_to_particulars, as: :doc, class_name: "PaymentParticular", conditions: { flag: "pay_to" }
  has_many :pay_from_particulars, as: :doc, class_name: "PaymentParticular", conditions: { flag: "pay_from" }
  has_many :matchers, class_name: 'TransactionMatcher', as: :doc
  has_many :transactions, as: :doc

  validates_presence_of :collector, :pay_to_name1, :pay_from_name1, :doc_date
  validates_numericality_of :actual_credit_amount, greater_than: 0
  validates_numericality_of :actual_debit_amount, greater_than: 0
  accepts_nested_attributes_for :pay_to_particulars, allow_destroy: true
  accepts_nested_attributes_for :pay_from_particulars, allow_destroy: true
  accepts_nested_attributes_for :matchers, allow_destroy: true, reject_if: :dont_process

  before_save :build_transactions

  include ValidateTransactionsBalance

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :actual_debit_amount,
             content: [:id, :pay_to_name1, :collector, :pay_to_particulars_audit_string, :actual_debit_amount, :matchers_audit_string,
                       :pay_from_name1, :cheque_date, :cheque_no, :pay_from_particulars_audit_string, :actual_credit_amount]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      pay_to: r.pay_to_name1,
      collector: r.collector,
      pay_to_particulars: r.pay_to_particulars_audit_string,
      actual_debit_amount: r.actual_debit_amount.to_money.format,
      matchers: r.matchers_audit_string,
      pay_from: r.pay_from_name1,
      cheque_no: r.cheque_no,
      cheque_date: r.cheque_date,
      pay_from_particulars: r.pay_from_particulars_audit_string,
      actual_credit_amount: r.actual_credit_amount.to_money.format
    }
  end

  scope :matched, -> { where(id: TransactionMatcher.uniq.where(doc_type: 'Payment').pluck(:doc_id)) }
  scope :not_matched, -> { where('id not in (?)', TransactionMatcher.uniq.where(doc_type: 'Payment').pluck(:doc_id) << -1) }

  include ValidateBelongsTo
  validate_belongs_to :pay_to, :name1
  validate_belongs_to :pay_from, :name1

  include AuditString
  audit_string :pay_to_particulars, :pay_from_particulars, :matchers

  include SumNestedAttributes
  sum_of :matchers, "amount"

private

  def dont_process(attr)
    return true if attr["id"].blank? && attr["amount"].to_f == 0
  end

  def build_transactions
    transactions.destroy_all
    pay_to_transaction
    pay_from_transaction
    build_particulars_transactions
    validates_transactions_balance
  end

  def build_particulars_transactions
    transactions <<
      pay_to_particulars.select { |t| !t.marked_for_destruction? }.
        map { |t| t.doc = self; t.transactions; }.select { |t| t != nil}

    transactions <<
      pay_from_particulars.select { |t| !t.marked_for_destruction? }.
        map { |t| t.doc = self; t.transactions; }.select { |t| t != nil}
  end

  def pay_from_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: pay_from,
      note: 'To ' + [pay_to.name1, collector].join(' by '),
      amount: -actual_debit_amount,
      user: User.current
    )
  end

  def pay_to_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: pay_to,
      note: 'From ' + [pay_from.name1, collector].join(' by '),
      amount: actual_debit_amount,
      self_matched: -matchers_amount,
      user: User.current
    )
  end
end
