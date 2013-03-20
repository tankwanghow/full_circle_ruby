class CreateFlocks < ActiveRecord::Migration
  def change
    create_table :flocks do |t|
      t.date    :dob,    null: false
      t.string  :breed, null: false
      t.integer :quantity, default: 0, null: false
      t.text    :note
      t.boolean :retired,       default: false
      t.integer :lock_version,  default: 0
      t.timestamps
    end
  end
end
