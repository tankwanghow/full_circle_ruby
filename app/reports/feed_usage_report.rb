class FeedUsageReport < Dossier::Report
  include SharedHelpers

  def sql
    <<-SQL
      select fu.feed_type, sum(fu.gross - fu.tare) as qty
        from feed_usages fu
       where usage_date >= :from_date
         and usage_date <= :to_date
       group by fu.feed_type
       order by 1
    SQL
  end

  def param_fields form
    form.input_field(:from_date, class: 'datepicker span3', placeholder: 'From...') +
    form.input_field(:to_date, class: 'datepicker span3', placeholder: 'To...')
  end

  def from_date
    @options[:from_date] ? @options[:from_date].to_date : Date.today
  end

  def to_date
    @options[:to_date] ? @options[:to_date].to_date : Date.today
  end  
  
end