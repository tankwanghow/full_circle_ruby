class ParticularType < ActiveRecord::Base
  belongs_to :account
  has_many :particulars
  validates_uniqueness_of :name
  validates_presence_of :party_type, :name, :account_name1

  include ValidateBelongsTo
  validate_belongs_to :account, :name1
  
  include Searchable
  searchable content: [:party_type, :name, :account_name1]

  simple_audit username_method: :username do |r|
    {
      party_type: r.party_type,
      name: r.name,
      account: r.account_name1
    }
  end

end