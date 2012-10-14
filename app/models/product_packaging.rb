class ProductPackaging < ActiveRecord::Base
  belongs_to :product
  belongs_to :packaging
  validates_uniqueness_of :product_id, scope: :packaging_id
  validates_uniqueness_of :packaging_id, scope: :product_id

  include ValidateBelongsTo
  validate_belongs_to :product,   :name1
  validate_belongs_to :packaging, :name

  def simple_audit_string
    [ product.name1, packaging.name, quantity.to_s, cost.to_money.to_s].join " "
  end

  def unit
    product.unit if product
  end
end