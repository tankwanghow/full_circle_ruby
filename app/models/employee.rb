class Employee < ActiveRecord::Base
  has_one :address, as: :addressable, conditions: ["addresses.address_type ~* ?", "mailing|both"], class_name: "Address", dependent: :destroy
  validates_presence_of :name, :id_no, :service_since, :birth_date
  validates_uniqueness_of :id_no
  has_many :salary_types, class_name: "EmployeeSalaryType"

  accepts_nested_attributes_for :salary_types, allow_destroy: true

  include Searchable
  searchable content: [:name, :id_no, :birth_date, :nationality, :socso_no, :tax_no, :epf_no, :status, :service_since]

  include AuditString
  audit_string :salary_types

  simple_audit username_method: :username do |r|
    {
      name: r.name,
      id_no: r.id_no,
      birth_date: r.birth_date,
      epf_no: r.epf_no,
      socso_no: r.socso_no,
      tax_no: r.tax_no,
      nationality: r.nationality,
      marital_status: r.marital_status,
      partner_working: r.partner_working,
      service_since: r.service_since,
      dependent: r.dependent,
      status: r.status,
      salary_types: r.salary_types_audit_string
    }
  end

  def self.new_with_salary_types
    a = new
    SalaryType.all.each do |t|
      a.salary_types.build(salary_type_name: t.name)
    end
    a
  end

  def self.new_like id
    sts = find(id).salary_types.map { |t| t.attributes.select { |k,v| k == 'salary_type_id' || k == 'amount' } }
    a = new
    sts.each do |t|
      a.salary_types.build t
    end
    a
  end

end
