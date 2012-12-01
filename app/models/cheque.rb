class Cheque < ActiveRecord::Base
  belongs_to :db_doc, polymorphic: true
  belongs_to :cr_doc, polymorphic: true
  belongs_to :db_ac, :class_name => "Account"
  belongs_to :cr_ac, :class_name => "Account"
  validates_presence_of :bank, :chq_no, :city, :state, :due_date, :amount
  validates_numericality_of :amount, greater_than: 0

  scope :credited, -> { where('cr_doc_type <> null and cr_doc_id <> null') }
  scope :not_credited, -> { where(cr_doc_type: nil, cr_doc_id: nil) } 
  scope :dued, ->(val) { where('due_date <= ?', val.to_date) }
  scope :cr_doc_is, ->(doc_type, doc_id) { where(cr_doc_type: doc_type, cr_doc_id: doc_id) }

  def simple_audit_string
    [ bank, chq_no, city, state, due_date.to_s, amount.to_money.format ].join ' '
  end
end
