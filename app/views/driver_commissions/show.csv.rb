if @body.count > 0
  response.headers["Content-Disposition"] = "attachment;filename=#{params[:options][:employee_tags]}.csv"

  CSV.generate do |csv|
    csv << @headers
    @body.each do |t|
      csv << t
    end
    csv << @footers
  end
end
