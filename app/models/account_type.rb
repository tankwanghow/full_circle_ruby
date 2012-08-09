class AccountType < ActiveRecord::Base
  attr_accessible :bf_balance, :dotted_ids, :lock_version, :name, :normal_balance, :parent_id, :description
  validate :parent?
  validates_presence_of :name
  validates_uniqueness_of :name
  acts_as_tree_with_dotted_ids order: :name
  has_many :accounts, dependent: :destroy

  include PgSearch
  
  include Searchable
  searchable content: [:parent_name, :name, :bf_balance, :normal_balance, :description]

  simple_audit username_method: :username do |r|
    {
      parent: r.parent_name,
      name: r.name,
      balance_bf: r.bf_balance,
      normal_balance: r.normal_balance,
      description: r.description
    }
  end

  def parent_name
    parent ? parent.name : nil
  end

  def parent?
    if parent_id.present?
      errors.add(:parent, "cannot assign parent.") if parent_id == id
    end
  end

end
