class FixedAsset < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :depreciation_rate
  validate :is_fixed_assets?
  has_many :additions, class_name: "AssetAddition"

  accepts_nested_attributes_for :additions, allow_destroy: true

  simple_audit username_method: :username do |r|
    {
      account: r.account.name1,
      depreciation_rate: r.depreciation_rate,
      final_amount: r.final_amount
    }
  end

  def cost_until entry_date=account.prev_close_date(Date.today)
    additions.where('year_end <= ?', entry_date).inject(0) { |sum, p| sum + p.amount }
  end

  def disposals_until entry_date=account.prev_close_date(Date.today)
    additions.where('year_end <= ?', entry_date).inject(0) { |sum, p| sum + p.cum_disposal_at(entry_date) }
  end

  def depreciations_until entry_date=account.prev_close_date(Date.today)
    additions.where('year_end <= ?', entry_date).inject(0) { |sum, p| sum + p.cum_depreciation_at(entry_date) }
  end

  def net_book_value_at entry_date=account.prev_close_date(Date.today)
    additions.where('year_end <= ?', entry_date).inject(0) { |sum, p| sum + p.net_book_value_at(entry_date) }
  end

private

  def is_fixed_assets?
    unless account.is_fixed_assets?
      errors.add :account, 'Not Fixed Assets Account.' 
    end
  end

end