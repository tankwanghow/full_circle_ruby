class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.date    :doc_date,     null: false
      t.date    :available_at, null: false
      t.integer :supplier_id,  null: false
      t.integer :product_id,   null: false
      t.decimal :quantity,     precision: 12, scale: 4, default: 0
      t.decimal :unit_price,   precision: 12, scale: 4, default: 0
      t.integer :product_packaging_id,   null: false
      t.boolean :fulfilled,   default: false
      t.boolean :active,       default: false
      t.text    :note
      t.integer :lock_version, default: 0
      t.timestamps
    end
  end
end
