CompanyName = 'Kim Poh Sitt Tat Feedmill Sdn. Bhd.'
ClosingDay = 31
ClosingMonth = 12
Date::DATE_FORMATS[:default] = '%d-%m-%Y'
Money.default_currency = Money::Currency.new('MYR')
CompanyAddress = Address.new do |t|
  t.address1 = 'No. 81, Golden Dragon Garden'
  t.address2 = nil
  t.address3 = nil
  t.area     = nil
  t.city     = 'Kampar'
  t.zipcode  = '31900' 
  t.state    = 'Perak'
  t.country  = 'Malaysia'
  t.tel_no   = '05-2563277'
  t.fax_no   = '016-9260462'
  t.reg_no   = '33704-U'
end