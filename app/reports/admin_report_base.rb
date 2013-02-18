class AdminReportBase < Dossier::Report
  
  def run
    if User.current.is_admin
      super
    else
      raise 'You not authorized to run Administrator Report.'
    end
  end
  
end