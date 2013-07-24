class Flock < ActiveRecord::Base
  validates_presence_of :dob, :breed
  has_many :movements

  accepts_nested_attributes_for :movements, allow_destroy: true

  include Searchable
  searchable doc_date: :dob, content: [:dob, :breed, :note, :retired, :movements_audit_string]

  simple_audit username_method: :username do |r|
    {
      dob: r.dob.to_s,
      breed: r.breed,
      note: r.note,
      retired: r.retired,
      movements: r.movements_audit_string
    }
  end

  def flock_info
    "#{dob.to_s} #{breed} *#{self.id.to_s}*"
  end

  def find_by_flock_info val
    Flock.find_by_id(val.scan(/\*(.+)\*/).flatten.first.to_i)
  end

  def age_at date=Date.today
    (date - dob) / 7
  end

  include AuditString
  audit_string :movements
end
