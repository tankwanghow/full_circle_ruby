class Payment < ActiveRecord::Base
  belongs_to :pay_to, class_name: "Account", foreign_key: "pay_to_id"
  belongs_to :pay_form, class_name: "Account", foreign_key: "pay_form_id"
  has_many :pay_to_particulars, class_name: "Particular", as: :doc
  has_many :pay_from_particulars, class_name: "Particular", as: :doc

  validates_presence_of :collector, :pay_to_id, :pay_form_id, :note, :pay_amount, :doc_date
  validates_numericality_of :payment_amount

end
