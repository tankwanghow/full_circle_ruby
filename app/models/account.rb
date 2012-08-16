class Account < ActiveRecord::Base
  belongs_to :account_type
  validates :account_type_id, presence: true
  validates :name1, presence: true, uniqueness: true
  
  include Searchable
  searchable content: [:name1, :name2, :type_name, :description, :status]

  simple_audit username_method: :username do |r|
    {
      account_type: r.type_name,
      name1: r.name1,
      name2: r.name2,
      admin_lock: r.admin_lock,
      description: r.description
    }
  end

  def type_name
    account_type.name
  end
end
