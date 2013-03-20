class CreateMovements < ActiveRecord::Migration
  def change
    create_table :movements do |t|
      t.date       :move_date, null: false
      t.belongs_to :house, null: false
      t.belongs_to :flock, null: false
      t.integer    :quantity,     default: 0, null: false
      t.string     :note
      t.integer    :lock_version, default: 0
      t.timestamps
    end
  end
end
