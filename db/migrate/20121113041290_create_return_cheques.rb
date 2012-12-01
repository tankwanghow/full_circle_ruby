class CreateReturnCheques < ActiveRecord::Migration
  def change
    create_table :return_cheques do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :return_to,    references: :accounts, null: false
      t.belongs_to :return_from,  references: :accounts, null: false
      t.belongs_to :cheque,       references: :cheques
      t.string     :reason,       null: false
      t.string     :bank,         null: false
      t.string     :chq_no,       null: false
      t.string     :city,         null: false
      t.string     :state,        null: false, default: '-'
      t.date       :due_date,     null: false
      t.decimal    :amount,       precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version,  default: 0
      t.timestamps
    end
  end
end
