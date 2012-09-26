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

  def payment_header_address_pdf address
    [address.address1, address.address2, address.address3,
     address.zipcode, address.city, address.state, address.country].map! do |t|
      !t.blank? ? sanitize(t) : nil
    end.compact.join(", ")
  end

  def payment_header_contact_pdf address
    tel = address.tel_no.blank? ? nil : "Tel No: #{address.tel_no}"
    fax = address.fax_no.blank? ? nil : "Fax No: #{address.fax_no}"
    em  = address.email.blank?  ? nil : "Email: #{address.email}"
    [tel, fax, em].compact.join(", ")
  end

end

