class Cheque < ActiveRecord::Base
  belongs_to :db_doc, polymorphic: true
  belongs_to :cr_doc, polymorphic: true
  validates_presence_of :bank, :chq_no, :city, :state, :due_date, :amount
  validates_numericality_of :amount, greater_than: 0

  scope :credited_cheques, -> { where('cr_doc_type <> null and cr_doc_id <> null') }
  scope :not_credited_cheques, -> { where(cr_doc_type: nil, cr_doc_id: nil) }
  scope :due_cheques, ->(val) { not_credited_cheques.where('due_date <= ?', val.to_date) }

  def simple_audit_string
    [ bank, chq_no, city, state, due_date.to_s, amount.to_money.format ].join ' '
  end
end
