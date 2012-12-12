class Employee < ActiveRecord::Base
  has_one :address, as: :addressable, conditions: ["addresses.address_type ~* ?", "mailing|both"], class_name: "Address", dependent: :destroy
  validates_presence_of :name, :id_no, :service_since
  validates_uniqueness_of :id_no

  include Searchable
  searchable content: [:name, :id_no, :nationality, :socso_no, :tax_no, :epf_no, :status, :service_since]

  simple_audit username_method: :username do |r|
    {
      name: r.name,
      id_no: r.id_no,
      epf_no: r.epf_no,
      socso_no: r.socso_no,
      tax_no: r.tax_no,
      nationality: r.nationality,
      marital_status: r.marital_status,
      partner_working: r.partner_working,
      service_since: r.service_since,
      dependent: r.dependent,
      status: r.status
    }
  end

end
