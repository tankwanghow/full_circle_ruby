class House < ActiveRecord::Base
  validates_uniqueness_of :house_no
  validates_presence_of :filling_wages, :feeding_wages, :cleaning_wages, :house_no
  validates_numericality_of :capacity, :filling_wages, :feeding_wages, :cleaning_wages, greater_than: -0.0001
  has_many :eggs_harvesting_wages
  has_many :movements
  has_many :harvesting_slip_details

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

  def self.empty_houses date
    House.all.select { |t| t.quantity_at(date) <= 0 }
  end

  def self.yield_less_than_at perc, date_1
    find_by_sql(report_sql(date_1.to_date.to_formatted_s(:db))).select { |t| t.yield.to_f < perc }
  end

  def self.alive_less_than_at perc, date_1
    find_by_sql(report_sql(date_1.to_date.to_formatted_s(:db))).select { |t| (t.movein.to_f - t.death.to_f) / t.movein.to_f < perc }
  end

  def yield_between date_1, date_2
    prod = production_between(date_1, date_2)
    move_in = Movement.where(house_id: id).where('move_date <= ?', date_2).sum(:quantity).to_i
    alive_1 = move_in - HarvestingSlipDetail.joins(:harvesting_slip).where(house_id: id).
                          where('harvesting_slips.harvest_date <= ?', date_1).
                          sum(:death).to_i
    alive_2 = move_in - HarvestingSlipDetail.joins(:harvesting_slip).where(house_id: id).
                          where('harvesting_slips.harvest_date <= ?', date_2).
                          sum(:death).to_i
    prod * 30.0 / (date_2.to_date - date_1.to_date + 1).to_f / ((alive_1 + alive_2) / 2.0)
  end

  def quantity_at date=Date.today
    Movement.where(house_id: id).where('move_date <= ?', date).sum(:quantity).to_i -
    HarvestingSlipDetail.joins(:harvesting_slip).
    where(house_id: id).where('harvesting_slips.harvest_date <= ?', date).sum(:death).to_i
  end

  def yield_at date=Date.today
    production_at(date).to_f * 30 / quantity_at(date).to_f
  end

  def production_at date=Date.today
    harvesting_slip_details.joins(:harvesting_slip).
      where('harvesting_slips.harvest_date = ?', date).sum('harvest_2 + harvest_1').to_i
  end

  def production_between date_1, date_2
    harvesting_slip_details.joins(:harvesting_slip).
      where('harvesting_slips.harvest_date >= ?', date_1).
      where('harvesting_slips.harvest_date <= ?', date_2).sum('harvest_2 + harvest_1').to_i
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

  def self.production_warning date=Date.today
    all.select do |h|
      (h.yield_between(date - 2, date) - h.yield_between(date - 9, date - 2)) <= -0.1 and
      h.flock_at(date).age_at(date) <= 79 and h.flock_at(date).age_at(date) >= 21
    end
  end

private
  
  def self.report_sql date
    "select house_no,
            #{production(date)} / (#{move_in(date)} - #{death(date)}) as yield,
            #{death(date)} as death, 
            #{move_in(date)} as movein
       from houses h left outer join harvesting_slip_details hsd
         on h.id = hsd.house_id left outer join flocks f
         on f.id = hsd.flock_id inner join harvesting_slips hs
         on hs.id = hsd.harvesting_slip_id
      where hs.harvest_date = '#{date}'"
  end

  def self.death date
    "(select sum(death)
        from harvesting_slip_details hsd1 inner join harvesting_slips hs1
          on hs1.id = hsd1.harvesting_slip_id
         and hsd1.flock_id = f.id 
         and hsd1.house_id = h.id
       where hs1.harvest_date <= '#{date}')"
  end

  def self.move_in date
    "(select sum(mv1.quantity) 
        from flocks f1 inner join movements mv1
          on mv1.flock_id = f1.id
       inner join houses h1 on h1.id = mv1.house_id
         and mv1.move_date <= '#{date}'
         and f1.id = f.id
         and h1.id = h.id)"
  end

  def self.production date
    "(select sum(hsd1.harvest_1 + hsd1.harvest_2) * 30.0
        from harvesting_slip_details hsd1 inner join harvesting_slips hs1
          on hs1.id = hsd1.harvesting_slip_id
         and hsd1.flock_id = f.id 
         and hsd1.house_id = h.id
       where hs1.harvest_date = '#{date}')"
  end

end