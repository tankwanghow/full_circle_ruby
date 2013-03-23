class Movement < ActiveRecord::Base
  belongs_to :house
  belongs_to :flock
  validates_presence_of :move_date, :quantity
  validates_numericality_of :quantity

  include ValidateBelongsTo
  validate_belongs_to :house, :house_no

  def simple_audit_string
    [ house.house_no, move_date.to_s, quantity.to_s, note ].join ' '
  end

  def cur_qty
    house.try(:current_quantity)
  end

end