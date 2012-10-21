class InvoiceDetail < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :product
  belongs_to :product_packaging
  validates_presence_of :product_name1, :unit
  validates_numericality_of :quantity, greater_than: 0
  
  include ValidateBelongsTo
  validate_belongs_to :product, :name1

  def total
    (quantity * unit_price).round 2
  end

  def simple_audit_string
    [ product.name1, note, packaging_name,
      package_qty.to_s, quantity.to_s,
      product.unit, unit_price.to_money.format ].join ' '
  end

  def unit
    product.unit if product
  end

  def transactions
    product_transaction
  end

  def packaging_name
    product_packaging.pack_qty_name if product_packaging
  end

  def packaging_name= val
    if !val.blank?
      pid = ProductPackaging.find_product_package(product_id, val).try(:id)
      if pid
        self.product_packaging_id = pid
      else
        error.add 'packaging_name', 'not found!'
      end
    else
      self.product_packaging_id = nil
    end
  end

private

  def product_transaction
    Transaction.new({
      doc: invoice, account: product.sale_account, transaction_date: invoice.doc_date, 
      note: invoice.customer.name1 + ' - ' + product.name1,
      amount: -total,
      user: User.current
    })
  end

end