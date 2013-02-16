class Journal < ActiveRecord::Base
  has_many :transactions, as: :doc
  validates_presence_of :doc_date

  accepts_nested_attributes_for :transactions, allow_destroy: true, reject_if: :dont_process

  include Searchable
  searchable doc_date: :doc_date, content: [:id, :transactions_audit_string]

  simple_audit username_method: :username do |r|
     {
      doc_date: r.doc_date.to_s,
      matchers: r.transactions_audit_string
     }
  end

  include AuditString
  audit_string :transactions

  before_validation :set_transaction_attributes

private

  def set_transaction_attributes
    transactions.each do |t| 
      t.transaction_date = doc_date
      t.doc = self
      t.user = User.current if !t.user
    end
  end
  
  def dont_process(attr)
    return true if attr["id"].blank? && attr["amount"].to_f == 0
  end

end
