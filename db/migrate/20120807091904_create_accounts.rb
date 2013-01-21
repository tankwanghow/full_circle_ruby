class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string     :name1,        null: false
      t.string     :name2
      t.belongs_to :account_type, null: false
      t.text       :description
      t.string     :status,       default: 'Active', null: false
      t.boolean    :admin_lock,   default: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end

    add_index :accounts, :name1, unique: true
  end
end
