class TaxCode < ActiveRecord::Base
  belongs_to :gst_account, :class_name => "Account", :foreign_key => "gst_account_id"
  validates_presence_of :tax_type, :code, :rate
  validates_numericality_of :rate

  include Searchable
  searchable content: [:tax_type, :code, :rate, :gst_account_name1, :description]

  include ValidateBelongsTo
  validate_belongs_to :gst_account, :name1

  scope :purchase, -> { where(tax_type: 'GST for Purchase') }
  scope :supply,   -> { where(tax_type: 'GST for Supply') }

  simple_audit username_method: :username do |r|
    {
      tax_type: r.tax_type,
      code: r.code,
      rate: r.rate,
      gst_account: r.gst_account_name1,
      description: r.description
    }
  end

end
