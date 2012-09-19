class Transaction < ActiveRecord::Base
  belongs_to :doc, polymorphic: true
  belongs_to :account
  belongs_to :user
  validates_numericality_of :debit, :credit
  validates_presence_of :transaction_date, :account, :note, :debit, :credit, :user, :doc
  
  include ValidateBelongsTo
  validate_belongs_to :account, :name1
  
  before_destroy :closed?

  scope :account, ->(val) { joins(:account).where('accounts.name1 = ?', val) }
  scope :bigger_eq,  ->(val) { where('transaction_date >= ?', val.to_date) }
  scope :smaller_eq,  ->(val) { where('transaction_date <= ?', val.to_date) }
  scope :bigger,  ->(val) { where('transaction_date > ?', val.to_date) }
  scope :smaller,  ->(val) { where('transaction_date < ?', val.to_date) }

  def terms_string
    return '-' unless terms
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
