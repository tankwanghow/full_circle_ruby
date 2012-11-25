class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.date       :doc_date,      null: false  
      t.belongs_to :bank,          references: :accounts, null: false
      t.decimal    :cash_amount,   default: 0, precision: 12, scale: 2
      t.integer    :lock_version,  default: 0
      t.timestamps
    end
  end
end
