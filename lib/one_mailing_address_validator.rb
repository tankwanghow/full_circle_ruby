class OneMailingAddressValidator <  ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value =~ /Mailing|Both/
    qry = Address.where(addressable_type: record.addressable_type).
      where(addressable_id: record.addressable_id).
      where("address_type ~* ?", "mailing|both")
    qry = qry.merge(Address.where("id <> ?", record.id)) unless record.new_record?
    record.errors[attribute] << "only one mailing is allow." if qry.count > 0
  end
end

