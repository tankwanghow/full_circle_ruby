class ChangeUnitPricePrecision < ActiveRecord::Migration
  def up
    change_column :cash_sale_details,   :unit_price, :decimal, precision: 12, scale: 6, default: 0
    change_column :invoice_details,     :unit_price, :decimal, precision: 12, scale: 6, default: 0
    change_column :pur_invoice_details, :unit_price, :decimal, precision: 12, scale: 6, default: 0
    change_column :particulars,         :unit_price, :decimal, precision: 20, scale: 6, default: 0
    change_column :salary_notes,        :unit_price, :decimal, precision: 12, scale: 6, default: 0
  end

  def down
    change_column :cash_sale_details,   :unit_price, :decimal, precision: 12, scale: 4, default: 0
    change_column :invoice_details,     :unit_price, :decimal, precision: 12, scale: 4, default: 0
    change_column :pur_invoice_details, :unit_price, :decimal, precision: 12, scale: 4, default: 0
    change_column :particulars,         :unit_price, :decimal, precision: 12, scale: 4, default: 0
    change_column :salary_notes,        :unit_price, :decimal, precision: 12, scale: 4, default: 0
  end
end
