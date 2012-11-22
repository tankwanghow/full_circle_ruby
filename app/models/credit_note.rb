class CreditNote < ActiveRecord::Base
  belongs_to :account
  has_many :particulars, as: :doc, class_name: "CreditNoteParticular"
  has_many :transactions, as: :doc
  has_many :matchers, class_name: 'TransactionMatcher', as: :doc

  validates_presence_of :account_id, :doc_date

  before_save :build_transactions

  accepts_nested_attributes_for :particulars, allow_destroy: true
  accepts_nested_attributes_for :matchers, allow_destroy: true, reject_if: :dont_process

  include ValidateBelongsTo
  validate_belongs_to :account, :name1

  include ValidateTransactionsBalance

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :credit_note_amount,
             content: [:id, :account_name1, :credit_note_amount, 
                       :particulars_string, :matchers_string]

  simple_audit username_method: :username do |r|
     {
      doc_date: r.doc_date.to_s,
      account: r.account_name1,
      particulars: r.particulars_string,
      matchers: r.matchers_string
     }
  end

  def matchers_string
    matchers.
      select { |t| !t.marked_for_destruction? }.
      map{ |t| t.simple_audit_string }.join(' ')
  end

  def particulars_string
    particulars.
      select { |t| !t.marked_for_destruction? }.
      map{ |t| t.simple_audit_string }.join(' ')
  end

  def credit_note_amount
    particulars.
      select { |t| !t.marked_for_destruction? }.
      inject(0) { |sum, p| sum + p.quantity * p.unit_price }
  end

private
  
  def dont_process(attr)
    return true if attr["id"].blank? && attr["amount"].to_f == 0
  end

  def build_transactions
    transactions.destroy_all
    build_account_transaction
    build_particulars_transactions
    validates_transactions_balance
  end

  def build_particulars_transactions
    particulars.select{ |t| !t.marked_for_destruction? }.each do |t|
      t.doc = self
      transactions << t.transactions
    end
  end

  def particulars_summary
    particulars.select{ |t| !t.marked_for_destruction? }.
      map { |t| t.particular_type.name + ' ' + t.note }.
      join(', ').truncate(70)
  end

  def build_account_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: account,
      note: particulars_summary,
      amount: -credit_note_amount,
      user: User.current)
  end
end
