class AddGstRelated < ActiveRecord::Migration
  def change
    add_column :addresses, :gst_no, :string, default: ''

    create_table :tax_codes do |t|
      t.string     :tax_type,       null: false
      t.string     :code,           null: false
      t.decimal    :rate,           precision: 5,  scale: 2, default: 0, null: false
      t.integer    :gst_account_id, null: false
      t.text       :description
      t.integer    :lock_version,   default: 0
      t.timestamps
    end

    add_index :tax_codes, :code, unique: true

    add_column :products, :supply_tax_code_id, :integer, null: false, default: 0
    add_column :products, :purchase_tax_code_id, :integer, null: false, default: 0

    add_column :cash_sale_details,   :discount, :decimal, precision: 12, scale: 2, default: 0
    add_column :invoice_details,     :discount, :decimal, precision: 12, scale: 2, default: 0
    add_column :pur_invoice_details, :discount, :decimal, precision: 12, scale: 2, default: 0
    add_column :cash_sale_details,   :tax_code_id, :integer
    add_column :invoice_details,     :tax_code_id, :integer
    add_column :pur_invoice_details, :tax_code_id, :integer
    add_column :cash_sale_details,   :gst_rate, :decimal, precision: 5, scale: 2, default: 0
    add_column :invoice_details,     :gst_rate, :decimal, precision: 5, scale: 2, default: 0
    add_column :pur_invoice_details, :gst_rate, :decimal, precision: 5, scale: 2, default: 0

    add_column :particular_types, :tax_code_id, :integer

    add_column :particulars, :tax_code_id, :integer
    add_column :particulars, :gst_rate, :decimal, precision: 5, scale: 2, default: 0

    change_column :cash_sale_details,   :package_qty, :decimal, precision: 12, scale: 2, default: 0
    change_column :invoice_details,     :package_qty, :decimal, precision: 12, scale: 2, default: 0
    change_column :pur_invoice_details, :package_qty, :decimal, precision: 12, scale: 2, default: 0

    add_column :credit_notes, :posted, :boolean, default: false, null: false
    add_column :debit_notes , :posted, :boolean, default: false, null: false
    add_column :pur_invoices, :posted, :boolean, default: false, null: false
    add_column :invoices    , :posted, :boolean, default: false, null: false
    add_column :cash_sales  , :posted, :boolean, default: false, null: false
    add_column :payments    , :posted, :boolean, default: false, null: false
  end

end