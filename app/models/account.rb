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

  def self.aging_lists accounts, at_date=Date.today, interval_days=15, intervals=5
    hash = {}
    accounts.each do |ac|
      hash[ac.id] = ac.aging_list at_date, interval_days, intervals
    end
    hash
  end

  def aging_list at_date=Date.today, interval_days=15, intervals=5
    hash = {}
    (0..intervals * interval_days).step(interval_days).each do |i|
      cur_date = at_date - i
      if i == intervals * interval_days
        prev_date = nil
        key = "more than #{i + interval_days} days"
      else
        prev_date = cur_date - interval_days
        key = "#{i + 1} - #{i + interval_days} days"
      end
      hash[key] = aging_interval(at_date, cur_date, prev_date)
    end
    hash
  end

  def payment_due at_date=Date.today
    results = transactions.smaller_eq(at_date)
    if results.count > 0
      results.select{ |t| t.terms != nil }.
        select{ |t| t.transaction_date + t.terms <= at_date }.
        inject(0.0){ |sum, t| sum += t.balance(at_date) }
    else
      0.0
    end
  end

private

  def aging_interval at_date, cur_date, prev_date=nil
    if prev_date
      results = transactions.smaller_eq(cur_date).bigger_eq(prev_date + 1)
    else
      results = transactions.smaller_eq(cur_date)
    end
    if results.count > 0
      results.inject(0.0) { |sum, t| sum += t.balance(at_date) }
    else
      0.0
    end  
  end

end