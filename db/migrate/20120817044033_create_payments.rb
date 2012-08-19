class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.date    :doc_date,             null: false
      t.integer :pay_to,               references: :accounts, null: false
      t.integer :pay_from,             references: :accounts, null: false
      t.string  :collector,            null: false
      t.string  :note,                 null: false
      t.decimal :pay_amount,           null: false, default: 0, precision: 12, scale: 2
      t.decimal :actual_debit_amount,  null: false, default: 0, precision: 12, scale: 2
      t.decimal :actual_credit_amount, null: false, default: 0, precision: 12, scale: 2
      t.date    :cheque_date
      t.string  :cheque_no
      t.string  :status
      t.integer :lock_version,          default: 0
      t.timestamps
    end
  end
end
