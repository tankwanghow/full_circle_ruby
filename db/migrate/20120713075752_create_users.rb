class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string     :username,        null: false
      t.string     :name
      t.string     :password_digest, null: false
      t.boolean    :is_admin,        default: false
      t.string     :status,          default: 'pending'
      t.integer    :lock_version,    default: 0
      t.timestamps
     end

     add_index :users, :username, unique: true
  end
end
