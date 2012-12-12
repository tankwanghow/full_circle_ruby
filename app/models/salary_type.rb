class SalaryType < ActiveRecord::Base
  belongs_to :cr_account, class_name: 'Account'
  belongs_to :db_account, class_name: 'Account'
  validates_presence_of :name, :classifiaction, :db_account_name1, :cr_account_name1
  validates_uniqueness_of :name
  
  include ValidateBelongsTo
  validate_belongs_to :db_account, :name1
  validate_belongs_to :cr_account, :name1

  include Searchable
  searchable content: [:name, :classifiaction, :db_account_name1, :cr_account_name1]

  simple_audit username_method: :username do |r|
    {
      name: r.name,
      classifiaction: r.classifiaction,
      db_account: r.db_account_name1,
      cr_account: r.cr_account_name1
    }
  end
end