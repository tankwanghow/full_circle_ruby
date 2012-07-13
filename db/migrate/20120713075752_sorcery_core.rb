class SorceryCore < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username,         :null => false  # if you use another field as a username, for example email, you can safely remove this field.
      t.string :name,             :null => false
      t.string :crypted_password, :default => nil
      t.string :salt,             :default => nil
      t.string :status,           :default => 'Pending'
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end