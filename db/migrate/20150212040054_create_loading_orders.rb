class CreateLoadingOrders < ActiveRecord::Migration
  def change
    create_table :loading_orders do |t|
      t.date    :doc_date,          null: false
      t.integer :sales_order_id
      t.integer :purchase_order_id
      t.text    :note
      t.integer :transporter_id
      t.string  :lorry_no
      t.integer :lock_version, default: 0
      t.timestamps
    end
  end
end
