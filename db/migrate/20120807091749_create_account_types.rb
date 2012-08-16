class CreateAccountTypes < ActiveRecord::Migration
  def change
    create_table :account_types do |t|
      t.integer :parent_id
      t.string  :dotted_ids
      t.string  :name,          null: false
      t.string  :normal_balance
      t.boolean :bf_balance,    default: true
      t.text    :description
      t.boolean :admin_lock,    default: false
      t.integer :lock_version,  default: 0
      t.timestamps
    end

    add_index :account_types, :name, unique: true
  end
end
