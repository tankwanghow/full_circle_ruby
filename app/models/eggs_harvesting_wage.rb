class EggsHarvestingWage < ActiveRecord::Base
  belongs_to :house
  validates_presence_of :prod_1, :prod_2, :wages
  validates_numericality_of :prod_1, :prod_2, :wages, greater_than: 0
  validate :prod_2_gt_prod_1
  
  def simple_audit_string
    [ prod_1.to_s, prod_2.to_s, wages.to_money.format ].join ' '
  end

private

  def prod_2_gt_prod_1
    errors.add(:prod_2, 'Must be greater than Prod 1') if prod_2 <= prod_1
  end

end
