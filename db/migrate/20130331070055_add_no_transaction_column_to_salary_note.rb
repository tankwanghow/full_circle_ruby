class AddNoTransactionColumnToSalaryNote < ActiveRecord::Migration
  def change
    add_column :salary_notes, :no_transactions, :boolean, defalut: false
  end
end
