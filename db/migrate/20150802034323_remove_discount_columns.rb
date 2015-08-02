class RemoveDiscountColumns < ActiveRecord::Migration
  def up
    remove_column :cash_sale_details,   :discount
    remove_column :invoice_details,     :discount
    remove_column :pur_invoice_details, :discount
  end

  def down
    add_column :cash_sale_details,   :discount, :decimal, precision: 12, scale: 2, default: 0
    add_column :invoice_details,     :discount, :decimal, precision: 12, scale: 2, default: 0
    add_column :pur_invoice_details, :discount, :decimal, precision: 12, scale: 2, default: 0
  end
end
