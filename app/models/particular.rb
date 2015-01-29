class Particular < ActiveRecord::Base

  belongs_to :particular_type
  belongs_to :doc, polymorphic: true
  belongs_to :tax_code

  validates_presence_of :particular_type_name, :unit
  validates_numericality_of :quantity, :unit_price

  include ValidateBelongsTo
  validate_belongs_to :particular_type, :name
  validate_belongs_to :tax_code, :code

  def simple_audit_string
    [ particular_type.name, quantity, unit_price, tax_code.code, gst_rate ].join ' '
  end

  def ex_gst_total
    (quantity * unit_price).round 2
  end

  def in_gst_total
    ex_gst_total + gst
  end

  def gst
    (gst_rate / 100 * ex_gst_total).round 2
  end

end
