class CashSale < ActiveRecord::Base
  belongs_to :customer, class_name: "Account"
  has_many :particulars, as: :doc, class_name: "CashSaleParticular"
  has_many :transactions, as: :doc
  has_many :details, order: 'product_id', class_name: "CashSaleDetail"
  has_many :cheques, as: :db_doc

  validates_presence_of :customer_id, :doc_date

  before_save :build_transactions

  accepts_nested_attributes_for :details, allow_destroy: true
  accepts_nested_attributes_for :particulars, allow_destroy: true
  accepts_nested_attributes_for :cheques, allow_destroy: true

  include ValidateBelongsTo
  validate_belongs_to :customer, :name1

  include ValidateTransactionsBalance

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :sales_amount,
             content: [:customer_name1, :details_string, :sales_amount, 
                       :note, :particulars_string, :cheques_string]

  simple_audit username_method: :username do |r|
     {
      doc_date: r.doc_date.to_s,
      customer: r.customer_name1,
      details: r.details_string,
      note: r.note,
      particulars: r.particulars_string,
      cheques: r.cheques_string
     }
  end

  def details_string
    details.
      select { |t| !t.marked_for_destruction? }.
      map{ |t| t.simple_audit_string }.join(' ')
  end

  def particulars_string
    particulars.
      select { |t| !t.marked_for_destruction? }.
      map{ |t| t.simple_audit_string }.join(' ')
  end

  def cheques_string
    cheques.
      select { |t| !t.marked_for_destruction? }.
      map{ |t| t.simple_audit_string }.join(' ')
  end

  def sales_amount
    particulars.
      select { |t| !t.marked_for_destruction? }.
      inject(0) { |sum, p| sum + p.quantity * p.unit_price } +
    details.
      select { |t| !t.marked_for_destruction? }.
      inject(0) { |sum, p| sum + p.quantity * p.unit_price }
  end

private

  def build_transactions
    transactions.destroy_all
    build_cash_n_pd_chq_transaction
    build_details_transactions
    build_particulars_transactions
    validates_transactions_balance
  end

  def build_details_transactions
    details.select { |t| t.total > 0 and !t.marked_for_destruction? }.each do |t|
      t.cash_sale = self
      transactions << t.transactions
    end
  end

  def build_particulars_transactions
    particulars.select{ |t| !t.marked_for_destruction? }.each do |t|
      t.doc = self
      transactions << t.transactions
    end
  end

  def product_summary
    details.select{ |t| !t.marked_for_destruction? }.map { |t| t.product.name1 }.join(', ').truncate(70)
  end

  def cheques_amount
    cheques.
      select { |t| !t.marked_for_destruction? }.
      inject(0) { |sum, p| sum + p.amount }
  end

  def build_cash_n_pd_chq_transaction
    cash_amount = sales_amount - cheques_amount

    if cash_amount < 0
      raise "Cheque Amount(#{cheques_amount.to_money.format}) cannot be larger than Sales Amount (#{sales_amount.to_money.format})."
    end

    if cash_amount > 0
      transactions.build(
        doc: self,
        transaction_date: doc_date,
        account: Account.find_by_name1('Cash in Hand'),
        note: product_summary,
        amount: cash_amount,
        user: User.current)
    end

    if cheques_amount > 0
      cheques.select { |t| !t.marked_for_destruction? }.each do |t|
        transactions.build(
          doc: self,
          transaction_date: doc_date,
          account: Account.find_by_name1('Post Dated Cheques'),
          note: [t.bank, t.chq_no, t.city, t.due_date].join(' '),
          amount: t.amount,
          user: User.current)
      end
    end
  end

end