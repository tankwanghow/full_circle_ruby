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
  end
end