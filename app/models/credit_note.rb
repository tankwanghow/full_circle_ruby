class CreditNote < ActiveRecord::Base
  belongs_to :account
  has_many :particulars, as: :doc, class_name: "CreditNoteParticular"
  has_many :transactions, as: :doc
  has_many :matchers, class_name: 'TransactionMatcher', as: :doc

  validates_presence_of :account_name1, :doc_date

  before_save do |r|
    if GstStarted
      if r.changes[:posted] == [false, true]
        if transactions.count == 0
          build_transactions
        else
          raise "Error!! Non-Posted document has accounting transactions. TELL BOSS!!"
        end
      elsif r.posted
        raise "Cannot update a posted document"
      end
    else
      build_transactions
    end
  end

  accepts_nested_attributes_for :particulars, allow_destroy: true
  accepts_nested_attributes_for :matchers, allow_destroy: true, reject_if: :dont_process

  include ValidateBelongsTo
  validate_belongs_to :account, :name1

  include ValidateTransactionsBalance

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :credit_note_amount,
             content: [:id, :account_name1, :credit_note_amount,
                       :particulars_audit_string, :matchers_audit_string, :posted]

  simple_audit username_method: :username do |r|
     {
      doc_date: r.doc_date.to_s,
      account: r.account_name1,
      particulars: r.particulars_audit_string,
      matchers: r.matchers_audit_string,
      posted: r.posted
     }
  end

  include AuditString
  audit_string :particulars, :matchers

  include SumAttributes
  sum_of :particulars, "in_gst_total"
  sum_of :matchers, "amount"

  def credit_note_amount
    particulars_amount
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
      join(', ').truncate(60)
  end

  def build_account_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: account,
      note: particulars_summary,
      amount: -credit_note_amount,
      self_matched: -matchers_amount,
      user: User.current)
  end
end
