class Address < ActiveRecord::Base
  validates_presence_of :addressable_type, :addressable_id, :address_type
  belongs_to :addressable, polymorphic: true
  validates :address_type, one_mailing_address: true

  simple_audit username_method: :username do |r|
    {
      addressable_type: r.addressable_type,
      addressable_id: r.addressable_id,
      address: [r.address1, r.address2, r.address3, r.zipcode,
                r.city, r.state, r.country].compact.join(", "),
      tel_no: r.tel_no,
      fax_no: r.fax_no,
      email: r.email,
      note: r.note
    }
  end

  def self.address_types
    ["Shipping", "Mailing", "Both"]
  end

end
