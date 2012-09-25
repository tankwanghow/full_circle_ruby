module AddressesHelper
  def html_format address
    [ 
      address.address1, address.address2, 
      address.address3, address.area,
      [address.zipcode, address.city].compact.join(" "),
      [address.state, address.country].compact.join(" "),
      address.tel_no ? "Tel." + address.tel_no : nil,
      address.fax_no ? "Fax." + address.fax_no : nil,
      address.email
    ].map! { |t| !t.blank? ? sanitize(t) : nil }.compact.join("<br/>").html_safe
  end
end

