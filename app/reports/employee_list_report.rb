class EmployeeListReport < Dossier::Report

  def sql
    Employee.select("name, birth_date, id_no, nationality").to_sql
  end
  
end