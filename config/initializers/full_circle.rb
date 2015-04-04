# encoding: utf-8
CompanyName = 'Kim Poh Sitt Tat Feedmill Sdn. Bhd.'
CompanyName1 = '金宝实达饲料厂有限公司'
ClosingDay = 31
ClosingMonth = 12
Date::DATE_FORMATS[:default] = '%d-%m-%Y'
Money.default_currency = Money::Currency.new('MYR')

# GST Stuff
GstStartDate = '2015-04-01'.to_date
GstStarted = (Date.today >= GstStartDate)
SoftwareVersion = '1.0.0'
GafVersion = ''

if Address.table_exists?
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
    t.fax_no   = nil
    t.reg_no   = '33704-U'
    t.gst_no   = '000162897920'
  end
end
