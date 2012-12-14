class CreatePayrolls < ActiveRecord::Migration
  def change
    create_table :advances do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :employee,     null: false
      t.belongs_to :pay_from,     references: :accounts, null: false
      t.string     :chq_no
      t.decimal    :amount,       precision: 12, scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.belongs_to :pay_slip
      t.timestamps
    end

    create_table :salary_notes do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :employee,     null: false
      t.belongs_to :salary_type,  null: false
      t.string     :note,         null: false
      t.decimal    :quantity,     precision: 12, scale: 4, default: 0, null: false
      t.string     :unit,         null: false,   default: '-'
      t.decimal    :unit_price,   precision: 12, scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.belongs_to :pay_slip
      t.belongs_to :recurring_note
      t.timestamps
    end

    create_table :recurring_notes do |t|
      t.date       :doc_date,      null: false
      t.belongs_to :employee,      null: false
      t.belongs_to :salary_type,   null: false
      t.string     :note,          null: false
      t.decimal    :amount,        precision: 12, scale: 4, default: 0, null: false
      t.decimal    :target_amount, precision: 12, scale: 4, default: 0, null: false
      t.date       :start_date,    null: false
      t.date       :end_date
      t.text       :note
      t.string     :status,        default: 'Active'
      t.integer    :lock_version,  default: 0
      t.timestamps
    end

    create_table :pay_slips do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :employee,     null: false
      t.integer    :pay_month,    null: false
      t.integer    :pay_year,     null: false
      t.belongs_to :pay_from,     references: :accounts, null: false
      t.string     :chq_no
      t.integer    :lock_version, default: 0
      t.timestamps
    end

  end
end
