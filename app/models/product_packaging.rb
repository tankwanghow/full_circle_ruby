class ProductPackaging < ActiveRecord::Base
  belongs_to :product
  belongs_to :packaging
  validates_uniqueness_of :product_id, scope: [:packaging_id, :quantity]
  validates_uniqueness_of :packaging_id, scope: [:product_id, :quantity]

  include ValidateBelongsTo
  validate_belongs_to :product,   :name1
  validate_belongs_to :packaging, :name

  before_save :set_pack_qty_name

  def simple_audit_string
    [ product.name1, packaging.name, quantity.to_s, cost.to_money.to_s].join " "
  end

  def unit
    product.unit if product
  end

  def self.pack_qty_names product_id, term
    like_term = "%#{term.scan(/(\w)/).flatten.join('%')}%"
    where('product_id = ? and pack_qty_name ilike ?', product_id, like_term).pluck(:pack_qty_name)
  end 

  def self.find_product_package product_id, packaging_name
    where(product_id: product_id, pack_qty_name: packaging_name).first
  end

private

  def set_pack_qty_name
    self.pack_qty_name = (quantity > 0 ? "#{quantity_string + product.unit}/" : '') + packaging.name
  end

  def quantity_string
    quantity.to_i == quantity ? quantity.to_i.to_s : quantity.to_s
  end

end