class CreateCashSalesReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.date       :doc_date,      null: false
      t.belongs_to :receive_from,  references: :accounts, null: false
      t.string     :collector,     null: false
      t.decimal    :chq_amount,    default: 0, precision: 12, scale: 2
      t.decimal    :cash_amount,   default: 0, precision: 12, scale: 2
      t.text     :note
      t.integer    :lock_version,  default: 0
      t.timestamps
    end

    create_table :cash_sales do |t|
      t.date       :doc_date,      null: false
      t.belongs_to :customer,  references: :accounts, null: false
      t.text     :note
      t.integer    :lock_version,  default: 0
      t.timestamps
    end

    create_table :cash_sale_details do |t|
      t.belongs_to :cash_sale, null: false
      t.belongs_to :product, null: false
      t.belongs_to :product_packaging
      t.decimal    :package_qty, default: 0, precision: 12, scale: 4
      t.decimal    :quantity,    default: 0, precision: 12, scale: 4
      t.decimal    :unit_price,  default: 0, precision: 12, scale: 4
      t.string     :note
      t.integer    :lock_version, default: 0
      t.timestamps
    end
  end
end
