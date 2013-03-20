class HarvestingSlipDetail < ActiveRecord::Base
  belongs_to :harvesting_slip
  belongs_to :house
  belongs_to :flock
  validates_presence_of :death, :harvest_1, :harvest_2
  validates_numericality_of :death, :harvest_1, :harvest_2, greater_than: -0.0001

  include ValidateBelongsTo
  validate_belongs_to :house, :house_no
  validate_belongs_to :flock, :flock_info

  def simple_audit_string
    [ house.house_no, flock.flock_info, harvest_1.to_s, harvest_2, death, note ].join ' '
  end

  def harvested
    harvest_1 + harvest_2
  end

end
