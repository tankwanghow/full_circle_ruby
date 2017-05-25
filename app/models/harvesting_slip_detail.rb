class HarvestingSlipDetail < ActiveRecord::Base
  belongs_to :harvesting_slip
  belongs_to :house
  belongs_to :flock
  validates_presence_of :house_house_no, :death, :harvest_1, :harvest_2
  validates_numericality_of :death, :harvest_1, :harvest_2, greater_than: -0.0001

  include ValidateBelongsTo
  validate_belongs_to :house, :house_no
  validate_belongs_to :flock, :flock_info

  validate :has_same_house_flock_and_harvest_date

  def simple_audit_string
    [ house.house_no, flock.flock_info, harvest_1.to_s, harvest_2, death, note ].join ' '
  end

  def harvested
    harvest_1 + harvest_2
  end

private

  def has_same_house_flock_and_harvest_date
    if new_record?
      hs = HarvestingSlipDetail.joins(:harvesting_slip).
            where(house_id: house_id, flock_id: flock_id).
            where("harvesting_slips.harvest_date = ?", harvesting_slip.try(:harvest_date)).first
    else
      hs = HarvestingSlipDetail.joins(:harvesting_slip).
            where(house_id: house_id, flock_id: flock_id).
            where('harvesting_slip_details.id != ?', id).
            where("harvesting_slips.harvest_date = ?", harvesting_slip.try(:harvest_date)).first
    end
    if hs
       errors.add "house_house_no", "entered slip no #{hs.harvesting_slip.id}"
     end
  end

end
