class FeedProductionUsageReport < Dossier::Report
  include SharedHelpers

  def sql
    <<-SQL
      select feed_type, sum(balance) as prev_bal, 
             sum(produce) as produce, 
             sum(usage)as usage, sum(balance + produce - usage) as balance
        from 
        (
           select feed_type, sum(produce - usage) as balance, 0 as produce, 0 as usage
             from 
             (
               select fu.feed_type, 0 as produce, sum(fu.gross - fu.tare) as usage
                 from feed_usages fu
                where usage_date < :from_date
                group by fu.feed_type
                union
               select fp.feed_type, sum(quantity) as produce, 0 as usage
                 from feed_productions fp
                where produce_date < :from_date
                group by fp.feed_type
              ) as temp
            group by feed_type
            union
            select feed_type, 0 as balance, sum(produce) as produce, sum(usage) as usage
              from 
              (
                select fu.feed_type, 0 as produce, sum(fu.gross - fu.tare) as usage
                  from feed_usages fu
                 where usage_date >= :from_date
                   and usage_date <= :to_date
                 group by fu.feed_type
                 union
                select fp.feed_type, sum(quantity) as produce, 0 as usage
                  from feed_productions fp
                 where produce_date >= :from_date
                   and produce_date <= :to_date
                 group by fp.feed_type
              ) as temp2
         group by feed_type
        ) as temp3
       group by feed_type
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