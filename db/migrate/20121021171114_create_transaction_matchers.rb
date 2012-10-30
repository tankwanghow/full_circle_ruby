class CreateTransactionMatchers < ActiveRecord::Migration
  def change
    create_table :transaction_matchers do |t|
      t.belongs_to :doc,            null: false, polymorphic: true
      t.belongs_to :transaction,    null: false
      t.decimal    :amount,         default: 0, precision: 12, scale: 4
      t.integer    :lock_version,   default: 0
      t.timestamps
    end
  end
end
