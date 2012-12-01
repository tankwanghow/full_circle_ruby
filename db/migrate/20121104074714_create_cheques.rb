class CreateCheques < ActiveRecord::Migration
  def change
    create_table :cheques do |t|
      t.belongs_to :db_doc,       null: false, polymorphic: true
      t.belongs_to :db_ac,        references: :accounts, null: false
      t.belongs_to :cr_doc,       polymorphic: true
      t.belongs_to :cr_ac,        references: :accounts
      t.string     :bank,         null: false
      t.string     :chq_no,       null: false
      t.string     :city,         null: false
      t.string     :state,        null: false,    default: '-'
      t.date       :due_date,     null: false
      t.decimal    :amount,       precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end
  end
end
