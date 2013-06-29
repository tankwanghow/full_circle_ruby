class Receipt < ActiveRecord::Base
  belongs_to :receive_from, class_name: "Account"
  has_many :transactions, as: :doc
  has_many :cheques, as: :db_doc
  has_many :matchers, class_name: 'TransactionMatcher', as: :doc

  validates_presence_of :receive_from_name1, :doc_date
  validates_numericality_of :cash_amount, greater_than: -0.0001

  before_save :build_transactions

  accepts_nested_attributes_for :cheques, allow_destroy: true
  accepts_nested_attributes_for :matchers, allow_destroy: true, reject_if: :dont_process

  include ValidateBelongsTo
  validate_belongs_to :receive_from, :name1

  include ValidateTransactionsBalance

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :receipt_amount,
             content: [:id, :receive_from_name1, :cash_amount, 
                       :note, :cheques_audit_string, :matchers_audit_string]

  simple_audit username_method: :username do |r|
     {
      doc_date: r.doc_date.to_s,
      customer: r.receive_from_name1,
      note: r.note,
      cash: r.cash_amount,
      cheques: r.cheques_audit_string,
      matchers: r.matchers_audit_string
     }
  end

  include AuditString
  audit_string :matchers, :cheques

  include SumAttributes
  sum_of :cheques, "amount"
  sum_of :matchers, "amount"

  def receipt_amount
    cheques_amount + cash_amount
  end

private
  
  def dont_process(attr)
    return true if attr["id"].blank? && attr["amount"].to_f == 0
  end

  def build_transactions
    transactions.destroy_all
    set_cheques_account
    build_cash_n_pd_chq_transaction
    build_receive_from_transaction
    validates_transactions_balance
  end

  def set_cheques_account
    cheques.select { |t| !t.marked_for_destruction? }.each do |t|
      t.db_ac = receive_from
    end
  end

  def build_receive_from_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: receive_from,
      note: transaction_note_summary,
      amount: -receipt_amount,
      self_matched: -matchers_amount,
      user: User.current)
  end

  def transaction_note_summary
    if cash_amount > 0 and cheques_amount > 0
      'Being Cash and ' + helpers.pluralize(cheques.size, 'cheque') + ' received'
    elsif  cash_amount > 0 and cheques_amount == 0
      'Being Cash received'
    elsif cash_amount == 0 and cheques_amount > 0
      'Being ' + helpers.pluralize(cheques.size, 'cheque') + ' received'
    end
  end

  def build_cash_n_pd_chq_transaction

    if cash_amount > 0
      transactions.build(
        doc: self,
        transaction_date: doc_date,
        account: Account.find_by_name1('Cash In Hand'),
        note: receive_from_name1,
        amount: cash_amount,
        user: User.current)
    end

    if cheques_amount > 0
      cheques.select { |t| !t.marked_for_destruction? }.each do |t|
        transactions.build(
          doc: self,
          transaction_date: doc_date,
          account: Account.find_by_name1('Post Dated Cheques'),
          note: "From #{receive_from_name1}, " + [t.bank, t.chq_no, t.city, t.due_date].join(' '),
          amount: t.amount,
          user: User.current)
      end
    end
  end

  def helpers
    ActionController::Base.helpers
  end
end
