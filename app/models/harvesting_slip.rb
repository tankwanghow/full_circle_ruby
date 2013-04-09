class HarvestingSlip < ActiveRecord::Base
  has_many :harvesting_slip_details
  belongs_to :salary_note
  validates_presence_of :harvest_date
  belongs_to :collector, class_name: "Employee"
  validate :has_detail
  # before_save :save_salary_note

  include ValidateBelongsTo
  validate_belongs_to :collector, :name

  accepts_nested_attributes_for :harvesting_slip_details, allow_destroy: true

  include Searchable
  searchable doc_date: :harvest_date, content: [:harvest_date, :collector_name, :harvesting_slip_details_audit_string]

  simple_audit username_method: :username do |r|
    {
      harvest_date: r.harvest_date.to_s,
      collector: r.collector_name,
      harvesting_slip_details: r.harvesting_slip_details_audit_string
    }
  end

  include AuditString
  audit_string :harvesting_slip_details

  def house_wages_summary
    harvesting_slip_details.select { |t| !t.marked_for_destruction? }.map do |t|
      "#{t.house.house_no}(#{t.house.harvesting_wages_for(t.harvested)})"
    end.join ' '
  end

  def harvesting_wages
    sum = 0.to_money
    harvesting_slip_details.select { |t| !t.marked_for_destruction? }.each do |t|
      sum = sum + t.house.harvesting_wages_for(t.harvested)
    end
    sum
  end

  def self.harvesting_slips_for date=Date.today - 1
    find_by_sql(["
      select e.name, string_agg(DISTINCT h.house_no, ' ' ORDER BY h.house_no) as houses
        from houses h
       inner join harvesting_slip_details hsd 
          on hsd.house_id = h.id
       inner join harvesting_slips hs 
          on hs.id = hsd.harvesting_slip_id
       inner join employees e
          on hs.collector_id = e.id 
       where hs.harvest_date = ?
       group by e.name", date.to_date - 1]).concat(
    find_by_sql ["
      select '' as name, string_agg(DISTINCT h.house_no, ' ' ORDER BY h.house_no) as houses
        from houses h
       inner join harvesting_slip_details hsd 
          on hsd.house_id = h.id
       inner join harvesting_slips hs 
          on hs.id = hsd.harvesting_slip_id
       where hs.harvest_date = ?
         and hs.collector_id is null", date.to_date - 1])
  end

private

  def has_detail
    if harvesting_slip_details.select{ |t| !t.marked_for_destruction? }.count == 0
      raise 'No detail Error.'
    end
  end

  def save_salary_note
    if collector
      if !salary_note
        create_salary_note!(
          doc_date: harvest_date,
          employee: collector,
          salary_type: SalaryType.find_by_name('By Piece Works'),
          note: house_wages_summary,
          quantity: 1,
          unit: '-',
          unit_price: harvesting_wages)
      else
        salary_note.update_attributes(
          doc_date: harvest_date,
          employee: collector,
          salary_type: SalaryType.find_by_name('By Piece Works'),
          note: house_wages_summary,
          quantity: 1,
          unit: '-',
          unit_price: harvesting_wages)
      end
    end
  end

end
