class AccountType < ActiveRecord::Base
  validate :parent?
  validates :name, presence: true, uniqueness: true
  acts_as_tree_with_dotted_ids order: :name
  has_many :accounts, dependent: :destroy

  before_save :set_children_bf_balance
  
  include Searchable
  searchable content: [:name, :parent_name, :bf_balance, :normal_balance, :description]

  simple_audit username_method: :username do |r|
    {
      parent: r.parent_name,
      name: r.name,
      balance_bf: r.bf_balance,
      normal_balance: r.normal_balance,
      admin_lock: r.admin_lock,
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

private

  def set_children_bf_balance
    self.bf_balance = parent.bf_balance if parent
    AccountType.update_all "bf_balance = #{self.bf_balance}", "dotted_ids LIKE '#{self.dotted_ids}.%'"
  end

end
