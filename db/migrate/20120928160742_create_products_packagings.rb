class CreateProductsPackagings < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string     :name1,               null: false
      t.string     :name2
      t.text       :description
      t.integer    :sale_account_id,     references: :accounts, null: false
      t.integer    :purchase_account_id, references: :accounts, null: false
      t.string     :unit,                null: false
      t.integer    :lock_version,        default: 0
      t.timestamps
    end

    create_table :product_packagings do |t|
      t.belongs_to  :product
      t.belongs_to  :packaging
      t.decimal     :quantity,     precision: 12,  scale: 4, default: 0, null: false
      t.decimal     :cost,         precision: 12,  scale: 4, default: 0, null: false
      t.integer     :lock_version, default: 0
      t.timestamps
    end

    create_table :packagings do |t|
      t.string  :name,         null: false
      t.integer :lock_version, default: 0
      t.timestamps
    end
  end
end
