class Product < ActiveRecord::Base
  belongs_to :sale_account,      class_name: "Account", foreign_key: "sale_account_id"
  belongs_to :purchase_account,  class_name: "Account", foreign_key: "purchase_account_id"
  belongs_to :supply_tax_code,   class_name: "TaxCode", foreign_key: "supply_tax_code_id"
  belongs_to :purchase_tax_code, class_name: "TaxCode", foreign_key: "purchase_tax_code_id"

  has_many :packagings, through: :product_packagings
  has_many :product_packagings
  has_many :cash_sale_details
  has_many :invoice_details
  has_many :pur_invoice_details
  validates_presence_of :sale_account_name1, :purchase_account_name1, :unit, :name1, :supply_tax_code_code, :purchase_tax_code_code
  validates_uniqueness_of :name1
  acts_as_taggable_on :categories

  accepts_nested_attributes_for :product_packagings, allow_destroy: true

  include ValidateBelongsTo
  validate_belongs_to :sale_account,     :name1
  validate_belongs_to :purchase_account, :name1
  validate_belongs_to :supply_tax_code, :code
  validate_belongs_to :purchase_tax_code, :code
  
  include Searchable
  searchable content: [:name1, :name2, :unit, :supply_tax_code, :purchase_tax_code, :sale_account_name1, 
                       :purchase_account_name1, :description, :category_list, :product_packagings_audit_string]

  simple_audit username_method: :username do |r|
    {
      name1: r.name1,
      name2: r.name2,
      unit: r.unit,
      supply_tax_code: r.supply_tax_code,
      purchase_tax_code: r.purchase_tax_code,
      sale_account: r.sale_account_name1,
      purchase_account: r.purchase_account_name1,
      description: r.description,
      categories: r.category_list,
      packagings: r.product_packagings_audit_string
    }
  end

  include AuditString
  audit_string :product_packagings

end
