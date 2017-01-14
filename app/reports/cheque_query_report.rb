class ChequeQueryReport < Dossier::Report
  include SharedHelpers

  def sql
    <<-SQL
    select ac.name1 as from_ac, db_doc_type as debit_doc, db_doc_id as debit_no,
           ac1.name1 as to_ac, cr_doc_type as credit_doc, cr_doc_id as credit_no,
           bank, chq_no, city, state, due_date, amount
      from cheques chq inner join accounts ac
        on chq.db_ac_id = ac.id left outer join accounts ac1
        on chq.cr_ac_id = ac1.id
     where 1 = 1
       #{start_date_condition}
       #{end_date_condition}
       #{amount}
       #{cheque_no_condition}
     order by due_date
    SQL
  end

  def start_date_condition
    condition 'start_date', '>=', 'due_date'
  end

  def end_date_condition
    condition 'end_date', '<=', 'due_date'
  end

  def amount_condition
    condition 'amount', '='
  end

  def cheque_no_condition
    condition 'chq_no', '='
  end

  def condition params, operator, field_name=nil
    if instance_eval(params).blank?
      ''
    else
      "AND #{field_name || params} #{operator} :#{params}"
    end
  end

  def param_fields form
    form.input_field(:chq_no, class: 'span5', placeholder: 'cheque no...') +
    form.input_field(:amount, class: 'span5', placeholder: 'amount...') +
    form.input_field(:start_date, class: 'datepicker span3', placeholder: 'start due date...') +
    form.input_field(:end_date, class: 'datepicker span3', placeholder: 'end due date...')
  end

  def start_date
    @options[:start_date] ? @options[:start_date].to_date : Date.today
  end

  def chq_no
    @options[:chq_no]
  end

  def amount
    @options[:amount]
  end

  def end_date
    @options[:end_date] ? @options[:end_date].to_date : Date.today
  end

end
