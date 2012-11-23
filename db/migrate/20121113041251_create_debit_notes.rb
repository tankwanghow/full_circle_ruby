class CreateDebitNotes < ActiveRecord::Migration
  def change
    create_table :debit_notes do |t|
      t.date       :doc_date,             null: false
      t.belongs_to :account,              references: :accounts, null: false
      t.integer    :lock_version,         default: 0
      t.timestamps
    end
  end
end
