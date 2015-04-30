class AddReferencesNo < ActiveRecord::Migration
  def up
    add_column :invoices,     :reference_no, :string
    add_column :pur_invoices, :reference_no, :string
  end

  def down
    remove_column :invoices,     :reference_no
    remove_column :pur_invoices, :reference_no
  end
end
