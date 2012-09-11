class Payment < ActiveRecord::Base
  belongs_to :pay_to, class_name: "Account", foreign_key: "pay_to_id"
  belongs_to :pay_from, class_name: "Account", foreign_key: "pay_from_id"
  has_many :pay_to_particulars, as: :doc, class_name: "Particular", conditions: { flag: "pay_to" }
  has_many :pay_from_particulars, as: :doc, class_name: "Particular", conditions: { flag: "pay_from" }
  has_many :transactions, as: :doc

  validates_presence_of :collector, :pay_to_name1, :pay_from_name1, :note, :pay_amount, :doc_date
  validates_numericality_of :pay_amount, :actual_credit_amount, :actual_debit_amount
  accepts_nested_attributes_for :pay_to_particulars, allow_destroy: true
  accepts_nested_attributes_for :pay_from_particulars, allow_destroy: true

  before_save :build_transaction

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :pay_amount,
             content: [:pay_to_name1, :collector, :note, :pay_amount, :pay_to_particulars_string, :actual_debit_amount,
                       :pay_from_name1, :cheque_date, :cheque_no, :pay_from_particulars_string, :actual_credit_amount, :status]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      pay_to: r.pay_to_name1,
      collector: r.collector,
      note: r.note,
      pay_amount: r.pay_amount.to_money.format,
      pay_to_particulars: r.pay_to_particulars_string,
      actual_debit_amount: r.actual_debit_amount.to_money.format,
      pay_from: r.pay_from_name1,
      cheque_no: r.cheque_no,
      cheque_date: r.cheque_date,
      pay_from_particulars: r.pay_from_particulars_string,
      actual_credit_amount: r.actual_credit_amount.to_money.format,
      status: r.status
    }
  end

  include ValidateBelongsTo
  validate_belongs_to :pay_to, :name1
  validate_belongs_to :pay_from, :name1

  def pay_to_particulars_string
    pay_to_particulars.map{ |t| t.simple_audit_string }.join('::')
  end

  def pay_from_particulars_string
    pay_from_particulars.map{ |t| t.simple_audit_string }.join('::')
  end


private

  def build_transaction
    transactions.destroy_all
    transactions.build credit_transaction
    transactions.build debit_transaction
  end

  def credit_transaction
    {
      doc: self,
      transaction_date: doc_date,
      terms: 0,
      account: pay_from,
      note: [cheque_no, pay_to.name1].keep_if { |t| !t.blank? }.join(" ").slice(0..50),
      debit: 0,
      credit: actual_credit_amount,
      user: User.current
    }
  end

  def debit_transaction
    {
      doc: self,
      transaction_date: doc_date,
      terms: 0,
      account: pay_to,
      note: [pay_from.name1.slice(0..20), cheque_no].keep_if { |t| !t.blank? }.join(" "),
      debit: actual_debit_amount,
      credit: 0,
      user: User.current
    }
  end

  def particulars_transaction
    pay_to_particulars.each do |p|
      transactions.build p.transaction
    end

    pay_from_particulars.each do |p|
      transaction.build p.transaction
    end
  end

end
