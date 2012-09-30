class Product < ActiveRecord::Base
  belongs_to :sale_account,     class_name: "Account", foreign_key: "sale_account_id"
  belongs_to :purchase_account, class_name: "Account", foreign_key: "purchase_account_id"
  validates_presence_of :sale_account_name1, :purchase_account_name1, :unit, :name1
  validates_uniqueness_of :name1
  acts_as_taggable_on :categories

  include ValidateBelongsTo
  validate_belongs_to :sale_account,     :name1
  validate_belongs_to :purchase_account, :name1
  
  include Searchable
  searchable content: [:name1, :name2, :unit, :sale_account_name1, :purchase_account_name1,
                       :description, :category_list]

  simple_audit username_method: :username do |r|
    {
      name1: r.name1,
      name2: r.name2,
      unit: r.unit,
      sale_account: r.sale_account.name1,
      purchase_account: r.purchase_account.name1,
      description: r.description,
      categories: r.category_list
    }
  end

end
