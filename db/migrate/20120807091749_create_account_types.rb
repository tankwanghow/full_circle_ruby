class CreateAccountTypes < ActiveRecord::Migration
  def change
    create_table :account_types do |t|
      t.integer :parent_id
      t.integer :dotted_ids
      t.string  :name,          null: false
      t.string  :normal_balance
      t.boolean :bf_balance,    default: true
      t.text    :description
      t.integer :lock_version,  default: 0
      t.timestamps
    end
  end
end
