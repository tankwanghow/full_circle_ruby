class ReturnCheque < ActiveRecord::Base
  belongs_to :return_to, class_name: 'Account'
  belongs_to :return_from, class_name: 'Account'
  has_many :transactions, as: :doc
  has_one :cheque, foreign_key: :id, primary_key: :cheque_id

  validates_presence_of :return_to_name1, :doc_date, :bank, :chq_no, :city, :state, :due_date, :amount, :reason, :return_from_name1
  validates_numericality_of :amount, greater_than: 0
  validates_uniqueness_of :cheque_id, message: "already returned."

  before_save :build_transactions

  include ValidateBelongsTo
  validate_belongs_to :return_to, :name1
  validate_belongs_to :return_from, :name1

  include ValidateTransactionsBalance

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :amount,
             content: [:id, :return_to_name1, :return_from_name1, :doc_date, :bank,
                       :chq_no, :city, :state, :reason]

  simple_audit username_method: :username do |r|
     {
      doc_date: r.doc_date.to_s,
      return_to: r.return_to_name1,
      from_bank: r.return_from_name1,
      reason: r.reason,
      bank: r.bank,
      chq_no: r.chq_no,
      city: r.city,
      state: r.state,
      due_date: r.due_date.to_s,
      amount: r.amount
     }
  end

private
  
  def dont_process(attr)
    return true if attr["id"].blank? && attr["amount"].to_f == 0
  end

  def build_transactions
    transactions.destroy_all
    set_cheque_cr_doc
    build_return_to_transaction
    build_return_from_transaction
    validates_transactions_balance
  end

  def set_cheque_cr_doc
    chq = Cheque.find cheque_id
    if !chq.cr_doc
      chq.cr_doc = self
      chq.cr_ac = return_to
      chq.save!
    end
  end

  def build_return_to_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      terms: 0,
      account: return_to,
      note: "#{reason}, " + [ bank, chq_no, city, state ].join(' '),
      amount: amount,
      user: User.current)
  end

  def build_return_from_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      account: return_from,
      note: "Return to #{return_to_name1}, " + [ bank, chq_no, city, state ].join(' '),
      amount: -amount,
      user: User.current)
  end
end
