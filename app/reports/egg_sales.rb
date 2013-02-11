class EggSales
  
  def self.from date
    CashSale.where('doc_date >= ?', date.to_date)
  end

  def self.to date
    CashSale.where('doc_date <= ?', date.to_date)
  end

  def self.tagged tags
    CashSale.tagged_with(tags)
  end

end