class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|
      t.date       :doc_date,     null: false
      t.integer    :lock_version,  default: 0
      t.timestamps
    end
  end
end
