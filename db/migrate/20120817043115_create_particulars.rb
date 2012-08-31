class CreateParticulars < ActiveRecord::Migration
  def change
    create_table :particulars do |t|
      t.belongs_to :doc,             null: false, polymorphic: true
      t.string     :flag
      t.belongs_to :particular_type, null: false
      t.string     :note,            null: false
      t.decimal    :quantity,        precision: 12,  scale: 4, default: 0, null: false
      t.string     :unit,            null: false,    default: '-'
      t.decimal    :unit_price,      precision: 12,  scale: 4, default: 0, null: false
      t.integer    :lock_version,    default: 0
      t.timestamps
    end
  end
end
