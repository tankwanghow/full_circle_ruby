class Particular < ActiveRecord::Base
  belongs_to :particular_type
  belongs_to :docable, polymorphic: true
  validates_presence_of :particular_type_name, :note, :unit
  validates_numericality_of :quantity, :unit_price

  include ValidateBelongsTo
  validate_belongs_to :particular_type, :name

  def simple_audit_string
    searchable_string
  end

  def searchable_string
    [ particular_type.name, note, quantity.to_s,
      unit, unit_price.to_money.format ].join ' '

  end

  def total
    (quantity * unit_price).round 2
  end

end
