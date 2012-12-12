class CreatePayrolls < ActiveRecord::Migration
  def change
    create_table :salary_types do |t|
      t.string     :name,           null: false
      t.string     :classifiaction, null: false
      t.belongs_to :db_account,     null: false
      t.belongs_to :cr_account,     null: false
      t.integer    :lock_version,   default: 0
      t.timestamps
    end

    create_table :salary_formats do |t|
      t.string     :name,         null: false
      t.integer    :lock_version, default: 0
      t.timestamps      
    end

    create_table :salary_format_details do |t|
      t.belongs_to :salary_format, null: false
      t.belongs_to :salary_type,   null: false      
      t.integer    :lock_version,  default: 0
      t.timestamps      
    end

    create_table :employee_salary_format_details do |t|
      t.belongs_to :employee,     null: false
      t.belongs_to :salary_type,  null: false
      t.decimal    :amount,       precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end    

    create_table :advances do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :employee,     null: false
      t.belongs_to :pay_from,     references: :accounts, null: false
      t.string     :chq_no
      t.decimal    :amount,       precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end

    create_table :addition_notes do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :employee,     null: false
      t.belongs_to :salary_type,  null: false
      t.string     :note,         null: false
      t.decimal    :quantity,     precision: 12,  scale: 4, default: 0, null: false
      t.string     :unit,         null: false,    default: '-'
      t.decimal    :unit_price,   precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end

    create_table :deduction_notes do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :employee,     null: false
      t.belongs_to :salary_type,  null: false
      t.string     :note,         null: false
      t.decimal    :quantity,     precision: 12,  scale: 4, default: 0, null: false
      t.string     :unit,         null: false,    default: '-'
      t.decimal    :unit_price,   precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end

    create_table :boss_contribution_notes do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :employee,     null: false
      t.belongs_to :salary_type,  null: false
      t.string     :note,         null: false
      t.decimal    :quantity,     precision: 12,  scale: 4, default: 0, null: false
      t.string     :unit,         null: false,    default: '-'
      t.decimal    :unit_price,   precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end

    create_table :worker_contribution_notes do |t|
      t.date       :doc_date,     null: false
      t.belongs_to :employee,     null: false
      t.belongs_to :salary_type,  null: false
      t.string     :note,         null: false
      t.decimal    :quantity,     precision: 12,  scale: 4, default: 0, null: false
      t.string     :unit,         null: false,    default: '-'
      t.decimal    :unit_price,   precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version, default: 0
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
