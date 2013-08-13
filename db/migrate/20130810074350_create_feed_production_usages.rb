class CreateFeedProductionUsages < ActiveRecord::Migration
  def change
    create_table :feed_usages do |t|
      t.date       :usage_date,   null: false
      t.string     :feed_type,    default: '-', null: false
      t.string     :lorry,        null: false
      t.integer    :gross,        default: 0,    null: false
      t.integer    :tare,         default: 0,    null: false
      t.string     :unit,         default: 'Kg', null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end

    create_table :feed_productions do |t|
      t.date       :produce_date, null: false
      t.string     :feed_type,    null: false
      t.integer    :quantity,     default: 0,    null: false
      t.string     :silo,         null: false
      t.string     :unit,         default: 'Kg', null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end
  end
end
