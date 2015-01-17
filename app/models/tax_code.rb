class TaxCode < ActiveRecord::Base
  validates_presence_of :tax_type, :code, :rate
  validates_numericality_of :rate

  include Searchable
  searchable content: [:tax_type, :code, :rate]

  simple_audit username_method: :username do |r|
    {
      tax_type: r.tax_type,
      code: r.code,
      rate: r.rate,
      description: r.description
    }
  end

end
