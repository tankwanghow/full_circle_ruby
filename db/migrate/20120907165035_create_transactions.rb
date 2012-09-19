class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.date       :transaction_date
      t.belongs_to :doc,            null: false, polymorphic: true
      t.belongs_to :account,        null: false
      t.integer    :terms
      t.string     :note,           null: false
      t.decimal    :debit ,         default: 0, precision: 12, scale: 2
      t.decimal    :credit,         default: 0, precision:  12, scale: 2
      t.boolean    :closed,         null: false, default: false
      t.boolean    :reconciled,     null: false, defautl: false
      t.belongs_to :user,           null: false
      t.integer    :lock_version,   default: 0
      t.timestamps
    end
  end
end
