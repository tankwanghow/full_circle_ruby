class Payment < ActiveRecord::Base
  belongs_to :pay_to, class_name: "Account", foreign_key: "pay_to_id"
  belongs_to :pay_from, class_name: "Account", foreign_key: "pay_from_id"
  has_many :pay_to_particulars, as: :doc, class_name: "PaymentParticular", conditions: { flag: "pay_to" }
  has_many :pay_from_particulars, as: :doc, class_name: "PaymentParticular", conditions: { flag: "pay_from" }
  has_many :transactions, as: :doc

  validates_presence_of :collector, :pay_to_name1, :pay_from_name1, :doc_date
  validates_numericality_of :actual_credit_amount, greater_than: 0
  validates_numericality_of :actual_debit_amount, greater_than: 0
  accepts_nested_attributes_for :pay_to_particulars, allow_destroy: true
  accepts_nested_attributes_for :pay_from_particulars, allow_destroy: true

  before_save :build_transactions

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :actual_debit_amount,
             content: [:pay_to_name1, :collector, :pay_to_particulars_string, :actual_debit_amount,
                       :pay_from_name1, :cheque_date, :cheque_no, :pay_from_particulars_string, :actual_credit_amount]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      pay_to: r.pay_to_name1,
      collector: r.collector,
      pay_to_particulars: r.pay_to_particulars_string,
      actual_debit_amount: r.actual_debit_amount.to_money.format,
      pay_from: r.pay_from_name1,
      cheque_no: r.cheque_no,
      cheque_date: r.cheque_date,
      pay_from_particulars: r.pay_from_particulars_string,
      actual_credit_amount: r.actual_credit_amount.to_money.format
    }
  end

  include ValidateBelongsTo
  validate_belongs_to :pay_to, :name1
  validate_belongs_to :pay_from, :name1

  def pay_to_particulars_string
    pay_to_particulars.map{ |t| t.simple_audit_string }.join(' ')
  end

  def pay_from_particulars_string
    pay_from_particulars.map{ |t| t.simple_audit_string }.join(' ')
  end

private

  def build_transactions
    transactions.destroy_all
    pay_to_transaction
    pay_from_transaction
  end

  def pay_from_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: pay_from,
      note: [pay_to.name1, collector].join(' - '),
      debit: 0,
      credit: actual_debit_amount,
      user: User.current
    )
  end

  def pay_to_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: pay_to,
      note: [pay_from.name1, collector].join(' - '),
      debit: actual_debit_amount,
      credit: 0,
      user: User.current
    )
  end
end
