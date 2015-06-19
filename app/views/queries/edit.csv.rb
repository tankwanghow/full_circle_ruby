if @results
  response.headers["Content-Disposition"] = "attachment;filename=#{@query.name.gsub(/\s/, '').underscore}.csv"
  CSV.generate do |csv|
    csv << @results[:header]
    @results[:data].each do |d|
      csv << d
    end
  end
end