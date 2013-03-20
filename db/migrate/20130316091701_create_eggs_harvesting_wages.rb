class CreateEggsHarvestingWages < ActiveRecord::Migration
  def change
    create_table :eggs_harvesting_wages do |t|
      t.belongs_to :house,  null: false
      t.integer    :prod_1, default: 0, null: false
      t.integer    :prod_2, default: 0, null: false
      t.decimal    :wages,  precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version,  default: 0
      t.timestamps
    end
  end
end
