class Account < ActiveRecord::Base
  belongs_to :account_type
  validates_presence_of :name1, :account_type_id
  validates_uniqueness_of :name1
  
  include Searchable
  searchable content: [:type_name, :name1, :name2, :description, :status]

  simple_audit username_method: :username do |r|
    {
      account_type: r.account_type.name,
      name1: r.name1,
      name2: r.name2,
      description: r.description
    }
  end

  def type_name
    account_type.name
  end
end
