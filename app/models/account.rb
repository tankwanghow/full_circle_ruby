class Account < ActiveRecord::Base
  belongs_to :account_type
  has_many :transactions
  has_many :addresses, as: :addressable, dependent: :destroy
  validates :account_type_id, presence: true
  validates :name1, presence: true, uniqueness: true
  has_one :mailing_address, as: :addressable, conditions: ["addresses.address_type ~* ?", "mailing|both"], class_name: "Address"
  has_one :fixed_asset, dependent: :destroy, validate: true

  include Searchable
  searchable content: [:name1, :name2, :type_name, :description, :status]

  simple_audit username_method: :username do |r|
    {
      account_type: r.type_name,
      name1: r.name1,
      name2: r.name2,
      admin_lock: r.admin_lock,
      description: r.description
    }
  end

  def is_fixed_assets?
    true if account_type.descendant_of?(AccountType.find_by_name 'Fixed Assets')
  end

  def type_name
    account_type.name
  end

  def bf_balance?
    account_type.bf_balance
  end

  def statement start_date, end_date
    bal = balance_before(start_date)
    balance = Transaction.new(doc_type: 'BF', note: 'Balance Brought Foward', amount: bal, transaction_date: start_date.to_date.yesterday)
    ([balance] << transactions.bigger_eq(start_date).smaller_eq(end_date).order("transaction_date")).flatten
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

  def prev_close_date date
    close_date = Date.new date.to_date.year, ClosingMonth, ClosingDay
    close_date >= date.to_date ? close_date.years_ago(1) : close_date
  end

end