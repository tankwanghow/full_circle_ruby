class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string     :name,         null: false
      t.text       :query,        null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end
  end
end