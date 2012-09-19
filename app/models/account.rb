class Account < ActiveRecord::Base
  belongs_to :account_type
  has_many :transactions
  validates :account_type_id, presence: true
  validates :name1, presence: true, uniqueness: true

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

  def type_name
    account_type.name
  end

  def bf_balance?
    account_type.bf_balance
  end

  def statement start_date, end_date
    bal = balance_before(start_date)
    if bal > 0
      balance = Transaction.new(doc_type: 'BF', note: 'Balance Brought Foward', debit: bal, transaction_date: start_date.to_date.yesterday)
    else
      balance = Transaction.new(doc_type: 'BF',note: 'Balance Brought Foward', credit: bal.abs, transaction_date: start_date.to_date.yesterday)
    end
    ([balance] << transactions.bigger_eq(start_date).smaller_eq(end_date).order("transaction_date")).flatten
  end

  def balance_at date
    BigDecimal(
      if bf_balance?
        transactions.smaller_eq(date).sum("debit - credit")
    else
      transactions.smaller(prev_close_date(date)).bigger_eq(date).sum("debit - credit")
    end)
  end

  def balance_before date
    BigDecimal(
      if bf_balance?
        transactions.smaller(date).sum("debit - credit")
    else
      transactions.bigger(prev_close_date(date)).smaller(date).sum("debit - credit")
    end)
  end

  def prev_close_date date
    close_date = Date.new date.to_date.year, ClosingMonth, ClosingDay
    close_date >= date.to_date ? close_date.years_ago(1) : close_date
  end

end