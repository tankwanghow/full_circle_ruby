class PurInvoice < ActiveRecord::Base
  belongs_to :supplier, class_name: "Account"
  has_many :particulars, as: :doc, class_name: "PurInvoiceParticular"
  has_many :transactions, as: :doc
  has_many :invoice_details, order: 'product_id', class_name: "PurInvoiceDetail"

  validates_presence_of :credit_terms, :supplier_id, :doc_date

  before_save :build_transactions

  accepts_nested_attributes_for :invoice_details, allow_destroy: true
  accepts_nested_attributes_for :particulars, allow_destroy: true

  include ValidateBelongsTo
  validate_belongs_to :supplier, :name1

  include ValidateTransactionsBalance

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :invoice_amount,
             content: [:supplier_name1, :credit_terms, :invoice_details_string, :invoice_amount, 
                       :note, :particulars_string]

  simple_audit username_method: :username do |r|
     {
      doc_date: r.doc_date.to_s,
      customer: r.supplier_name1,
      credit_terms: r.credit_terms,
      invoice_details: r.invoice_details_string,
      note: r.note,
      particulars: r.particulars_string
     }
  end

  def invoice_details_string
    invoice_details.map{ |t| t.simple_audit_string }.join(' ')
  end

  def particulars_string
    particulars.map{ |t| t.simple_audit_string }.join(' ')
  end

  def invoice_amount
    particulars.inject(0) { |sum, p| sum + p.quantity * p.unit_price } +
    invoice_details.inject(0) { |sum, p| sum + p.quantity * p.unit_price }
  end

private

  def build_transactions
    transactions.destroy_all
    build_supplier_transaction
    build_details_transactions
    build_particulars_transactions
    validates_transactions_balance
  end

  def build_details_transactions
    invoice_details.select { |t| t.total > 0 and !t.marked_for_destruction? }.each do |t|
      t.pur_invoice = self
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
    invoice_details.select{ |t| !t.marked_for_destruction? }.map { |t| t.product.name1 }.join(', ').truncate(70)
  end

  def build_supplier_transaction
    transactions.build(
      doc: self,
      transaction_date: doc_date,
      terms: credit_terms,
      account: supplier,
      note: product_summary,
      amount: -invoice_amount,
      user: User.current
    )
  end
end
