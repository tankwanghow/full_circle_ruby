class CreateParticularTypes < ActiveRecord::Migration
  def change
    create_table :particular_types do |t|
      t.string     :party_type,   null: false
      t.string     :name,         null: false
      t.belongs_to :account,   null: false
      t.integer    :lock_version, default: 0
      t.timestamps
    end
  end
end
