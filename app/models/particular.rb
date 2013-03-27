class Particular < ActiveRecord::Base

  belongs_to :particular_type
  belongs_to :doc, polymorphic: true
  validates_presence_of :particular_type_name, :unit
  validates_numericality_of :quantity, :unit_price

  include ValidateBelongsTo
  validate_belongs_to :particular_type, :name

  def simple_audit_string
    [ particular_type.name, note ].join ' '
  end

  def total
    (quantity * unit_price).round 2
  end

end
