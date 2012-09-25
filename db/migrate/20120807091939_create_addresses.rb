class CreateAddresses < ActiveRecord::Migration
 def change
    create_table :addresses do |t|
      t.belongs_to :addressable, polymorphic: true
      t.string     :address1, :address2, :address3, :area, :city, :zipcode
      t.string     :state, :country, :tel_no, :fax_no, :email, :reg_no
      t.string     :address_type, null: false
      t.text       :note
      t.integer    :lock_version, default: 0
      t.timestamps
     end
  end
end
