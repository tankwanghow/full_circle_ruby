class Payment < ActiveRecord::Base
  belongs_to :pay_to, class_name: "Account", foreign_key: "pay_to_id"
  belongs_to :pay_form, class_name: "Account", foreign_key: "pay_form_id"
  has_many :pay_to_particulars, class_name: "Particular", as: :doc, conditions: { flag: "pay_to" }
  has_many :pay_from_particulars, class_name: "Particular", as: :doc, conditions: { flag: "pay_from" }

  validates_presence_of :collector, :pay_to_name, :pay_form_name, :note, :pay_amount, :doc_date
  validates_numericality_of :payment_amount

  accepts_nested_attributes_for :pay_to_particulars, allow_destroy: true
  accepts_nested_attributes_for :pay_from_particulars, allow_destroy: true

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :actual_debit_amount, 
             content: [:pay_to_name, :collector, :note, :pay_amount, 
              :actual_credit_amount, :cheque_date, :cheque_no, :status,
              :pay_to_particulars, :pay_from_particulars]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      pay_to: r.pay_to_name,
      collector: r.collector,
      note: r.note,
      pay_amount: r.pay_amount.to_money.format,
      pay_to_particulars: r.pay_to_particulars_string,
      actual_debit_amount: r.actual_debit_amount.to_money.format,
      pay_from_particulars: r.pay_from_particulars_string,
      cheque_no: r.cheque_no,
      cheque_date: r.cheque_date,
      actual_credit_amount: r.actual_credit_amount.to_money.format,
      status: r.status
    }
  end

  def pay_to_name
    pay_to ? pay_to.name1 : nil
  end

  def pay_to_name= val
    self.pay_to_id = Account.find_by_name1(val).id
  end

  def pay_from_name
    pay_from ? pay_from.name1 : Account.where('name1 ilike ?', 'cash in hand').first.name1
  end

  def pay_from_name= val
    self.pay_from_id = (Account.find_by_name1(val) || Account.where('name1 ilike ?', 'cash in hand').first).id
  end

  def pay_to_particulars_string
    pay_to_particulars.map{ |t| t.simple_audit_string }.join('::')
  end

  def pay_from_particulars_string
    pay_from_particulars.map{ |t| t.simple_audit_string }.join('::')
  end  

end
