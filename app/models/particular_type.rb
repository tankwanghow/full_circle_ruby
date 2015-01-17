class ParticularType < ActiveRecord::Base
  belongs_to :account
  belongs_to :supply_tax_code
  belongs_to :supply_tax_code,   class_name: "TaxCode", foreign_key: "supply_tax_code_id"
  belongs_to :purchase_tax_code, class_name: "TaxCode", foreign_key: "purchase_tax_code_id"

  has_many :particulars
  validates_uniqueness_of :name
  validates :name, presence: true
  validates :account_name1, presence: true, if: Proc.new { |r| !r.party_type.blank? }
  validates :party_type, presence: true, if: Proc.new { |r| !r.account_name1.blank? }
  validates_presence_of :supply_tax_code_code, :purchase_tax_code_code

  include ValidateBelongsTo
  validate_belongs_to :account, :name1
  validate_belongs_to :supply_tax_code, :code
  validate_belongs_to :purchase_tax_code, :code

  include Searchable
  searchable content: [:party_type, :name, :account_name1, :supply_tax_code, :purchase_tax_code]

  simple_audit username_method: :username do |r|
    {
      party_type: r.party_type,
      name: r.name,
      account: r.account_name1,
      supply_tax_code: r.supply_tax_code,
      purchase_tax_code: r.purchase_tax_code
    }
  end

  def name_nil_if_note
    self.name == 'Note' ? nil : self.name
  end

end