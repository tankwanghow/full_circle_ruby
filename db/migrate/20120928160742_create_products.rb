class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :name1,               null: false
      t.string  :name2
      t.text    :description
      t.integer :sale_account_id,     references: :accounts, null: false
      t.integer :purchase_account_id, references: :accounts, null: false
      t.string  :unit,                null: false
      t.integer :lock_version,        default: 0
      t.timestamps
    end
  end
end
