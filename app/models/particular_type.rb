class ParticularType < ActiveRecord::Base
  belongs_to :account
  has_many :particulars
  validates_uniqueness_of :name
  validates_presence_of :party_type, :name, :account_id

  def account_type_id
  end
  
  include Searchable
  searchable content: [:party_type, :name, :account_name]

  simple_audit username_method: :username do |r|
    {
      party_type: r.party_type,
      name: r.name,
      account: r.account_name
    }
  end

  def account_name
    account.name1
  end
end