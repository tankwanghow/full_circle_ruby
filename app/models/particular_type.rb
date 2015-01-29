class ParticularType < ActiveRecord::Base
  belongs_to :account
  belongs_to :tax_code

  has_many :particulars
  validates_uniqueness_of :name
  validates :name, presence: true
  validates :account_name1, presence: true, if: Proc.new { |r| !r.party_type.blank? }
  validates :party_type, presence: true, if: Proc.new { |r| !r.account_name1.blank? }
  validates_presence_of :tax_code_code

  include ValidateBelongsTo
  validate_belongs_to :account,  :name1
  validate_belongs_to :tax_code, :code

  scope :using, -> { where('party_type != ?', 'Stopped') }

  include Searchable
  searchable content: [:party_type, :name, :account_name1, :tax_code]

  simple_audit username_method: :username do |r|
    {
      party_type: r.party_type,
      name: r.name,
      supply_account: r.account_name1,
      tax_code: r.tax_code
    }
  end

  def name_nil_if_note
    self.name == 'Note' ? nil : self.name
  end

end