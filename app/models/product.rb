class Product < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :name1, :account_id, :unit
  validates_uniqueness_of :name1
  acts_as_taggable_on :categories

  include ValidateBelongsTo
  validate_belongs_to :account, :name1
  
  include Searchable
  searchable content: [:name1, :name2, :unit, :account_name1, :description, :category_list]

  simple_audit username_method: :username do |r|
    {
      name1: r.name1,
      name2: r.name2,
      unit: r.unit,
      account: r.account.name1,
      description: r.description,
      categories: r.category_list
    }
  end

end
