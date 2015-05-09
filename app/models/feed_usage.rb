class FeedUsage < ActiveRecord::Base
  validates :usage_date, presence: true
  validates :lorry, presence: true
  validates_numericality_of :gross, :tare, :message => "is not a number"

  validate :gross_tare_not_too_small

  def self.daily_usage_summary date=Date.today
    sql = <<-SQL
      select feed_type, sum(gross - tare) as Qty
        from feed_usages
       where usage_date = '#{date.to_s(:db)}'
       group by feed_type
       order by 1
    SQL
    find_by_sql(sql)
  end

private
  def gross_tare_not_too_small
    if gross - tare <= 60
      errors.add :gross, 'check value'
      errors.add :tare, 'check value'
    end
  end

end
