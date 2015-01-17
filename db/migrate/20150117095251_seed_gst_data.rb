class SeedGstData < ActiveRecord::Migration
  def up
  	tax = TaxCode.create! tax_type: 'NOTGST', code: 'NOTSPEC', rate: 0, 
  	                      description: 'Not a Tax Code. Is use by the system to implementation of GST'
	Product.update_all supply_tax_code_id: tax.id, purchase_tax_code_id: tax.id
	ParticularType.update_all supply_tax_code_id: tax.id, purchase_tax_code_id: tax.id
  end

  def down
  	Product.update_all supply_tax_code_id: nil, purchase_tax_code_id: nil
  	ParticularType.update_all supply_tax_code_id: nil, purchase_tax_code_id: nil
  	TaxCode.destroy_all(code: 'NOTSPEC')
  end
end
