class House < ActiveRecord::Base
  validates_uniqueness_of :house_no
  validates_presence_of :filling_wages, :feeding_wages, :cleaning_wages, :house_no
  validates_numericality_of :capacity, :filling_wages, :feeding_wages, :cleaning_wages, greater_than: -0.0001
  has_many :eggs_harvesting_wages
  has_many :movements

  accepts_nested_attributes_for :eggs_harvesting_wages, allow_destroy: true

  include Searchable
  searchable content: [:house_no, :capacity, :filling_wages, :feeding_wages, :cleaning_wages, :eggs_harvesting_wages_audit_string]

  simple_audit username_method: :username do |r|
    {
      house_no: r.house_no,
      capacity: r.capacity,
      filling_wages: r.filling_wages.to_money.format,
      feeding_wages: r.feeding_wages.to_money.format,
      cleaning_wages: r.cleaning_wages.to_money.format,
      eggs_harvesting_wages: r.eggs_harvesting_wages_audit_string
    }
  end

  include AuditString
  audit_string :eggs_harvesting_wages

  def last_move_in date
    Movement.where(house_id: id).where('move_date <= ?', date).order(:move_date).last
  end

  def flock_at date=Date.today
    if quantity_at(date) > 0
      last_move_in(date).flock
    else
      nil
    end
  end

  def quantity_at date=Date.today
    Movement.where(house_id: id).where('move_date <= ?', date).sum(:quantity).to_i -
    HarvestingSlipDetail.joins(:harvesting_slip).
    where(house_id: id).where('harvesting_slips.harvest_date <= ?', date).sum(:death).to_i
  end

  def harvesting_wages_for(harvested)
    wages = eggs_harvesting_wages.where('prod_1 <= ?', harvested).where('prod_2 >= ?', harvested)
    if wages.count > 1
      raise "Ambigious wages for #{house_no}"
    elsif wages.count == 0
      raise "Wages not found for #{house_no}"
    else
      wages.first.wages.to_money
    end
  end

end
