class Transaction < ActiveRecord::Base
  belongs_to :doc, polymorphic: true
  belongs_to :account
  belongs_to :user
  validates_numericality_of :amount
  validates_presence_of :transaction_date, :account, :note, :amount, :user, :doc
  
  before_destroy :closed?

  scope :account, ->(val) { joins(:account).where('accounts.name1 = ?', val) }
  scope :bigger_eq,  ->(val) { where('transaction_date >= ?', val.to_date) }
  scope :smaller_eq,  ->(val) { where('transaction_date <= ?', val.to_date) }
  scope :bigger,  ->(val) { where('transaction_date > ?', val.to_date) }
  scope :smaller,  ->(val) { where('transaction_date < ?', val.to_date) }

  private

  def closed?
    raise 'Transactions closed CANNOT update or delete!' if closed 
  end

end
