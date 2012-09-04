class Payment < ActiveRecord::Base
  belongs_to :pay_to, class_name: "Account", foreign_key: "pay_to_id"
  belongs_to :pay_from, class_name: "Account", foreign_key: "pay_from_id"
  has_many :particulars, as: :doc

  validates_presence_of :collector, :pay_to_name1, :pay_from_name1, :note, :pay_amount, :doc_date
  validates_numericality_of :pay_amount
  accepts_nested_attributes_for :particulars, allow_destroy: true

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :pay_amount,
             content: [:pay_to_name1, :collector, :note, :pay_amount,
              :actual_credit_amount, :pay_from_name1, :cheque_date, :cheque_no, :status,
              :particulars_string]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      pay_to: r.pay_to_name1,
      collector: r.collector,
      note: r.note,
      pay_amount: r.pay_amount.to_money.format,
      pay_from: r.pay_from_name1,
      particulars: r.particulars_string,
      cheque_no: r.cheque_no,
      cheque_date: r.cheque_date,
      actual_credit_amount: r.actual_credit_amount.to_money.format,
      status: r.status
    }
  end

  include ValidateBelongsTo
  validate_belongs_to :pay_to, :name1
  validate_belongs_to :pay_from, :name1

  def particulars_string
    particulars.map{ |t| t.simple_audit_string }.join('::')
  end

end
