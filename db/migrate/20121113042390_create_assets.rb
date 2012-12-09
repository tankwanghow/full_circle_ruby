class CreateAssets < ActiveRecord::Migration
  def change
    create_table :fixed_assets do |t|
      t.belongs_to :account,           null: false
      t.decimal    :depreciation_rate, precision: 5, scale: 4, default: 0, null: false
      t.integer    :lock_version,      default: 0
      t.timestamps
    end

    create_table :asset_additions do |t|
      t.belongs_to :fixed_asset,        null: false
      t.date       :entry_date,   null: false
      t.decimal    :amount,       precision: 12, scale: 4, default: 0, null: false
      t.decimal    :final_amount, precision: 12, scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end

    create_table :asset_disposals do |t|
      t.belongs_to :asset_addition, null: false
      t.date       :entry_date,     null: false
      t.decimal    :amount,         precision: 12, scale: 4, default: 0, null: false
      t.integer    :lock_version,   default: 0
      t.timestamps
    end

    create_table :asset_depreciations do |t|
      t.belongs_to :asset_addition, null: false
      t.date       :entry_date,     null: false
      t.decimal    :amount,         precision: 12, scale: 4, default: 0, null: false
      t.integer    :lock_version,   default: 0
      t.timestamps
    end
  end
end