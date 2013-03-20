class CreateHarvestingSlips < ActiveRecord::Migration
  def change
    create_table :harvesting_slips do |t|
      t.date       :harvest_date, null: false
      t.belongs_to :salary_note
      t.belongs_to :collector, references: :employees
      t.integer    :lock_version, default: 0
      t.timestamps
    end

    create_table :harvesting_slip_details do |t|
      t.belongs_to :harvesting_slip, null: false
      t.belongs_to :house, null: false
      t.belongs_to :flock, null: false
      t.integer    :harvest_1, null: false, default: 0
      t.integer    :harvest_2, default: 0
      t.integer    :death, null: false, default: 0
      t.string     :note
      t.integer    :lock_version, default: 0
      t.timestamps
    end
  end
end
