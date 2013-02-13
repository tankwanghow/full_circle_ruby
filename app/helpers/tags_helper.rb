module TagsHelper
  def sales_doc_tags
    CashSale.tag_counts.map {|t| t.name }.concat(Invoice.tag_counts.map {|t| t.name }).uniq
  end
end