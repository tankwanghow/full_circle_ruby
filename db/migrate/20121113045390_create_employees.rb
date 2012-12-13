class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string     :name,           null: false
      t.string     :id_no,          null: false
      t.string     :epf_no
      t.string     :socso_no
      t.string     :tax_no
      t.string     :nationality,     default: 'Malaysian'
      t.string     :marital_status,  default: 'Single'
      t.boolean    :partner_working, default: false
      t.date       :service_since,   null: false
      t.integer    :dependent,       null: false, default: 0
      t.string     :status,          default: 'active', null: false
      t.integer    :lock_version,    default: 0
      t.timestamps
    end

    create_table :salary_types do |t|
      t.string     :name,           null: false
      t.string     :classifiaction, null: false
      t.belongs_to :db_account
      t.belongs_to :cr_account
      t.integer    :lock_version,   default: 0
      t.timestamps
    end

    create_table :employee_salary_format_details do |t|
      t.belongs_to :employee,     null: false
      t.belongs_to :salary_type,  null: false
      t.decimal    :amount,       precision: 12, scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end

  end
end