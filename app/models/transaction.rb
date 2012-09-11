class Transaction < ActiveRecord::Base
  belongs_to :doc, polymorphic: true
  belongs_to :account
  belongs_to :user
  validates_numericality_of :debit, :credit
  validates_presence_of :transaction_date, :account, :note, :debit, :credit, :user, :doc

  before_destroy :closed?

  include Searchable
  searchable doc_date: :transaction_date, doc_amount: :transaction_amount,
             content: [:account_name, :doc_type, :doc_id, :terms, :note,
                       :debit, :credit, :closed, :reconciled]

  def terms_string
    return nil unless terms
    return "#{t} days" if terms >= 2
    return "#{t} day" if terms == 1
    return "C.O.D." if terms == 0
    return "C.B.D." if terms == -1
  end

  def account_name
    account.name1
  end

  def transaction_amount
    debit > 0 ? debit : credit
  end

  private

  def closed?
    raise 'Transactions closed CANNOT update or delete!' if closed 
  end

end