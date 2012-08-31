class ParticularType < ActiveRecord::Base
  belongs_to :account
  has_many :particulars
  validates_uniqueness_of :name
  validates_presence_of :party_type, :name, :account_name
  
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
    account ? account.name1 : nil
  end

  def account_name= val
    self.account_id = Account.find_by_name1(val).try(:id)
  end

end