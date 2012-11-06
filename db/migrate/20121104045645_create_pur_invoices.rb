class CreatePurInvoices < ActiveRecord::Migration
  def change
    create_table :pur_invoices do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :supplier,  null: false
      t.integer    :credit_terms, null: false, default: 0
      t.text       :note
      t.integer    :lock_version, default: 0
      t.timestamps
    end

    create_table :pur_invoice_details do |t|
      t.belongs_to :pur_invoice, null: false
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