class GstAuditFile

  def initialize start_date, end_date
    @start_date = start_date
    @end_date = end_date
    @file_creation_date = Date.today
    @date_format = "%d/%m/%Y"
  end

  def c_record_elements
    [
      'C', CompanyName, CompanyAddress.reg_no, CompanyAddress.gst_no, 
      @start_date.strftime(@date_format), @end_date.strftime(@date_format),
      @file_creation_date.strftime(@date_format), SoftwareVersion, GafVersion
    ]
  end

  def p_record_elements
 
  end
 
end