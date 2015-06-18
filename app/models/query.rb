class Query < ActiveRecord::Base
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  validates_presence_of :query, :on => :create, :message => "can't be blank"

  before_save :clean_up_dangerous_query

  def run
    results = connection.execute(query)
    header = results.map { |t| t.map { |k,v| k } }.uniq.flatten
    data   = results.map { |t| t.map { |k,v| v } }
    header.push "No Result" if header.count == 0
    data.push ["No Result"] if data.count == 0
    { header: header, data: data}
  end

private

  def clean_up_dangerous_query
    
  end

end
