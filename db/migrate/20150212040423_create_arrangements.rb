class CreateArrangements < ActiveRecord::Migration
  def change
    create_table :arrangements do |t|
      t.integer :sales_order_id
      t.integer :purchase_order_id
      t.integer :loading_order_id
      t.decimal :quantity, precision: 12, scale: 4, default: 0
      t.integer :invoice_id
      t.integer :pur_invoice_id
      t.integer :lock_version, default: 0
      t.timestamps
    end
  end
end
