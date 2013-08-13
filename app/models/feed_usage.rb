class FeedUsage < ActiveRecord::Base
  validates :usage_date, presence: true
  validates :lorry, presence: true

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

end
