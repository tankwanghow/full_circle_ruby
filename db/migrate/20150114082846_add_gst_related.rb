class AddGstRelated < ActiveRecord::Migration
	def change
		add_column :addresses, :gst_no, :string, default: ''

		create_table :tax_codes do |t|
			t.string     :tax_type,        null: false
			t.string     :code,        null: false
      t.decimal    :rate,        precision: 5,  scale: 4, default: 0, null: false
      t.text       :description
      t.integer    :lock_version,    default: 0
      t.timestamps
		end

		add_index :tax_codes, :code, unique: true

		add_column :products, :supply_tax_code_id, :integer, null: false, default: 0
		add_column :products, :purchase_tax_code_id, :integer, null: false, default: 0

		add_column :particular_types, :supply_tax_code_id, :integer, null: false, default: 0
		add_column :particular_types, :purchase_tax_code_id, :integer, null: false, default: 0
	end

end