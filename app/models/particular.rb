class Particular < ActiveRecord::Base
  belongs_to :particular_type
  belongs_to :docable, polymorphic: true
  validates_presence_of :party_type_name, :note
  validates_numericality_of :quantity, :unit_price

  def party_type_name
    particular_type ? particular_type.name : nil
  end

  def party_type_name= val
    self.particular_type_id = ParticularType.find_by_name(val).id
  end

  def simple_audit_string
    searchable_string
  end

  def searchable_string
    [ party_type.name, note, quantity.to_s, 
      unit, unit_price.to_money.format ].join ' '

  end

  def total
    (quantity * unit_price).round 2
  end
end
