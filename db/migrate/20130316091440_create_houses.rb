class CreateHouses < ActiveRecord::Migration
  def change
    create_table :houses do |t|
      t.string  :house_no, null: false
      t.integer :capacity, null: false, default: 0
      t.decimal :filling_wages,  precision: 12,  scale: 4, default: 0, null: false
      t.decimal :feeding_wages,  precision: 12,  scale: 4, default: 0, null: false
      t.decimal :cleaning_wages,  precision: 12,  scale: 4, default: 0, null: false
      t.integer :lock_version,  default: 0
      t.timestamps
    end
  end
end
