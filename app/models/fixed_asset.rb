class FixedAsset < ActiveRecord::Base
  include SharedHelpers
  belongs_to :account
  validates_presence_of :depreciation_rate
  validate :is_fixed_assets?
  has_many :additions, class_name: "AssetAddition", order: 'entry_date', dependent: :destroy
  validates_numericality_of :depreciation_rate, greater_than_or_equal_to: 0, less_than_or_equal_to: 1
  default_scope includes(:additions)

  accepts_nested_attributes_for :additions, allow_destroy: true

  simple_audit username_method: :username do |r|
    {
      account: r.account.name1,
      depreciation_rate: r.depreciation_rate
    }
  end

  def cost_until entry_date=prev_close_date(Date.today)
    additions.where('entry_date <= ?', entry_date).inject(0) { |sum, p| sum + p.amount }
  end

  def disposals_until entry_date=prev_close_date(Date.today)
    additions.where('entry_date <= ?', entry_date).inject(0) { |sum, p| sum + p.cum_disposal_at(entry_date) }
  end

  def depreciations_until entry_date=prev_close_date(Date.today)
    additions.where('entry_date <= ?', entry_date).inject(0) { |sum, p| sum + p.cum_depreciation_at(entry_date) }
  end

  def net_book_value_at entry_date=prev_close_date(Date.today)
    additions.where('entry_date <= ?', entry_date).inject(0) { |sum, p| sum + p.net_book_value_at(entry_date) }
  end

  def fill_in_unsaved_additions_until end_year=Date.today.year-1  
    values = unsaved_additions_attributes(end_year)
    if values.count > 0
      values.each { |t| additions.build(t) }
    end
  end

  def unsaved_additions_attributes end_year=Date.today.year-1
    rtnval = []
    if additions.count > 0
      start_year = additions.order(:entry_date).last.entry_date.year 
    else
      if account.transactions.count > 0
        start_year = account.transactions.order(:transaction_date).first.transaction_date.year
      else
        start_year = end_year
      end
    end
    addition_transaction_years(start_year, end_year).each do |y|
      end_date = "#{y}-#{ClosingMonth}-#{ClosingDay}".to_date
      start_date = prev_close_date(end_date) + 1
      if !additions.detect { |t| t.entry_date == end_date }
        sum = sum_of_unsaved_additions_from_transactions start_date, end_date
        if sum > 0
          rtnval << { entry_date: end_date, amount: sum }
        end
      end
    end
    rtnval
  end

private

  def addition_transaction_years start_year, end_year
    account.transactions.where('amount > 0').where("doc_type <> 'Balance'").
    where('extract(year from transaction_date) >= ?', start_year).
    where('extract(year from transaction_date) <= ?', end_year).
    pluck('distinct extract(year from transaction_date)')
  end

  def sum_of_unsaved_additions_from_transactions start_date, end_date
    account.transactions.where('amount > 0').
      where("doc_type <> 'Balance'").
      where('transaction_date >= ?', start_date).
      where('transaction_date <= ?', end_date).sum(:amount)
  end

  def is_fixed_assets?
    unless account.is_fixed_assets?
      errors.add :account, 'Not Fixed Assets Account.' 
    end
  end

end