class Transaction < ActiveRecord::Base
  belongs_to :doc, polymorphic: true
  belongs_to :account
  belongs_to :user
  has_many :matchers, :class_name => "TransactionMatcher", :foreign_key => "transaction_id", dependent: :restrict
  validates_numericality_of :amount
  validates_presence_of :transaction_date, :account, :note, :amount, :user, :doc
  
  before_destroy :closed?

  scope :account,    ->(val) { joins(:account).where('accounts.name1 = ?', val) }
  scope :bigger_eq,  ->(val) { where('transaction_date >= ?', val.to_date) }
  scope :smaller_eq, ->(val) { where('transaction_date <= ?', val.to_date) }
  scope :bigger,     ->(val) { where('transaction_date > ?', val.to_date) }
  scope :smaller,    ->(val) { where('transaction_date < ?', val.to_date) }

  def simple_audit_string
    [ transaction_date, doc_type, doc_id, account.name1, terms, note, amount, closed, reconciled ].join("_")
  end

  def closed?
    raise 'Transactions closed CAN#NOT update or delete!' if closed 
  end

  include SumAttributes
  sum_of :matchers, "amount"

  include ValidateBelongsTo
  validate_belongs_to :account, :name1

  def balance
    amount + matchers_amount
  end

  def self.with_matched_amount_and_balance account_name1, in_doc_type, in_doc_id, from, to
    ac = Account.find_by_name1(account_name1)
    in_doc_id = in_doc_id.blank? ? -1 : in_doc_id
    if ac
      matching = <<-BOL 
        (SELECT COALESCE(SUM(amount), 0) FROM transaction_matchers
           WHERE transaction_id = transactions.id
             AND doc_type = '#{in_doc_type}'
             AND doc_id = #{in_doc_id}) AS matching
      BOL
      matched = <<-BOL
        (SELECT COALESCE(SUM(amount), 0) FROM transaction_matchers
           WHERE transaction_id = transactions.id
             AND id NOT IN (SELECT id FROM transaction_matchers
                             WHERE doc_type = '#{in_doc_type}'
                               AND doc_id = #{in_doc_id})) AS matched
      BOL
      matcher_id = <<-BOL
        (SELECT id FROM transaction_matchers 
          WHERE transaction_id = transactions.id 
            AND doc_type = '#{in_doc_type}' 
            AND doc_id = #{in_doc_id}) AS matcher_id
      BOL
       Transaction.
         select(["transactions.*", matched, matching, matcher_id].join(', ')).
         where(account_id: ac.id).bigger_eq(from).smaller_eq(to).order("transaction_date").
         where('doc_type || doc_id <> ?', "#{in_doc_type}#{in_doc_id}").
         where(decide_debit_or_credit_transaction? in_doc_type)
    end
  end

private

  def self.decide_debit_or_credit_transaction? in_doc_type
    case in_doc_type
    when "Payment"
      'amount < 0'
    when "Receipt"
      'amount > 0'
    when "CreditNote"
      'amount > 0'
    when "DebitNote"
      'amount < 0'
    when "ReturnCheque"
      'amount < 0'
    else
      '1=1'
    end
  end

end
