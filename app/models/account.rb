class Account < ActiveRecord::Base
  include SharedHelpers

  belongs_to :account_type
  has_many :transactions, dependent: :restrict
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :sales_orders, class_name: "sales_orders", foreign_key: "customer_id"
  validates :account_type_id, presence: true
  validates :name1, presence: true, uniqueness: true
  has_one :mailing_address, as: :addressable, conditions: ["addresses.address_type ~* ?", "mailing|both"], class_name: "Address"
  has_one :fixed_asset, dependent: :destroy, validate: true

  include Searchable
  searchable content: [:name1, :name2, :type_name, :description, :status]

  scope :gst_accounts, -> { where("name1 like 'GST - %'") }

  simple_audit username_method: :username do |r|
    {
      account_type: r.type_name,
      name1: r.name1,
      name2: r.name2,
      admin_lock: r.admin_lock,
      description: r.description
    }
  end

  def can_delete?
    !transactions.exists?
  end

  def is_fixed_assets?
    true if account_type.descendant_of?(AccountType.find_by_name 'Fixed Assets') or account_type.name == 'Fixed Assets'
  end

  def is_descendant_of_type?(name)
    true if account_type.descendant_of?(AccountType.find_by_name name) or account_type.name == name
  end

  def type_name
    account_type.name
  end

  def bf_balance?
    account_type.bf_balance
  end

  def statement start_date, end_date
    bal = balance_before(start_date)
    balance = Transaction.new(doc_type: 'BF', note: 'Balance Brought Foward', account: self, amount: bal || 0, transaction_date: start_date.to_date.yesterday)
    ([balance] << transactions.bigger_eq(start_date).smaller_eq(end_date).order("transaction_date, doc_type, doc_id")).flatten
  end

  def balance_at date
    BigDecimal(
      if bf_balance?
        transactions.smaller_eq(date).sum(:amount)
      else
        transactions.smaller(prev_close_date(date)).bigger_eq(date).sum(:amount)
      end)
  end

  def balance_before date
    BigDecimal(
      if bf_balance?
        transactions.smaller(date).sum(:amount)
      else
        transactions.bigger(prev_close_date(date)).smaller(date).sum(:amount)
      end)
  end

  def aging_list at_date=Date.today, interval_days=15, intervals=5
    AccountAging.new(self, at_date, interval_days, intervals).aging_list
  end

end
