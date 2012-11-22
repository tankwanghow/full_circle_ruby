class TransactionMatcher < ActiveRecord::Base
  belongs_to :transaction
  belongs_to :doc, polymorphic: true
  validates_uniqueness_of :transaction_id, scope: [:doc_type, :doc_id]
  validates_presence_of :transaction_id, :amount
  validates_numericality_of :amount

  delegate :transaction_date, to: :transaction
  delegate :amount, :terms, to: :transaction, prefix: :trans

  def simple_audit_string
    [ self.transaction.doc_type, "##{self.transaction.doc_id}",
      self.amount.to_money.format ].join("_")
  end

  def matched
    TransactionMatcher.where("transaction_id = ? and id <> ?", transaction.id, self.id).sum(:amount)
  end

  def self_matched
    if transaction.doc.respond_to?(:matchers)
      transaction.doc.matchers.sum(:amount)
    else
      0
    end
  end

  def trans_doc_type_id
    transaction.doc_type + (" #%07d" % transaction.doc_id)
  end

  def _destroy
    false
  end

end
