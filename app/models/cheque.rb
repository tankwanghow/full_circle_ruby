class Cheque < ActiveRecord::Base
  belongs_to :db_doc, polymorphic: true
  belongs_to :cr_doc, polymorphic: true
  belongs_to :db_ac, :class_name => "Account"
  belongs_to :cr_ac, :class_name => "Account"
  validates_presence_of :bank, :chq_no, :city, :state, :due_date, :amount
  validates_numericality_of :amount, greater_than: 0

  before_validation :validates_due_date
  before_destroy :destroy_check_credited
  before_update :update_check_credited

  scope :credited, -> { where('cr_doc_type <> null and cr_doc_id <> null') }
  scope :not_credited, -> { where(cr_doc_type: nil, cr_doc_id: nil) }
  scope :dued, ->(val) { where('due_date <= ?', val.to_date) }
  scope :cr_doc_is, ->(doc_type, doc_id) { where(cr_doc_type: doc_type, cr_doc_id: doc_id) }

  def simple_audit_string
    [ bank, chq_no, city, state, due_date.to_s, amount.to_money.format ].join ' '
  end

  def credited?
    !cr_doc_id.nil? || !cr_ac_id.nil? || !cr_doc_type.nil?
  end

private

  def validates_due_date
    check_date = db_doc ? db_doc.doc_date : Date.today
    if due_date <= check_date - 160 || due_date >= check_date + 100
      errors.add "due_date", "unacceptable"
    end
  end

  def update_check_credited
    if (changed - ["cr_doc_id", "cr_doc_type", "cr_ac_id"]).count != 0
      raise "Cannot UPDATE a credited cheque #{cr_doc_type} #{cr_doc_id}" if credited?
    end
  end

  def destroy_check_credited
    raise "Cannot DELETE a credited cheque #{cr_doc_type} #{cr_doc_id}" if credited?
  end
end
