class RecurringNote < ActiveRecord::Base
  belongs_to :salary_type
  belongs_to :employee
  validates_presence_of :employee_name, :salary_type_name, :doc_date, :start_date, :status, :note
  validates_numericality_of :amount, greater_than: 0
  validates_numericality_of :target_amount

  include Searchable
  searchable doc_date: :doc_date, doc_amount: :amount,
             content: [:id, :employee_name , :salary_type_name, :note, :amount,
                       :target_amount, :start_date, :end_date, :status]

  simple_audit username_method: :username do |r|
    {
      doc_date: r.doc_date.to_s,
      employee: r.employee_name,
      salary_type: r.salary_type_name,
      note: r.note,
      amount: r.amount.to_money.format,
      target_amount: r.target_amount.to_money.format,
      start_date: r.start_date,
      end_date: r.end_date,
      status: r.status
    }
  end

  include ValidateBelongsTo
  validate_belongs_to :employee, :name
  validate_belongs_to :salary_type, :name

end
