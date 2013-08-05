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

  def cur_qty_n_flock
    cur_flock = house.try(:flock_at)
    "#{cur_flock.try(:dob).to_s} #{cur_flock.try(:breed)} *#{cur_flock.try(:id)}* (#{house.try(:quantity_at)})"
  end

end
