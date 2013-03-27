module TagsHelper
  def sales_doc_tags
    CashSale.tag_counts.map {|t| t.name }.
    concat(Invoice.tag_counts.map {|t| t.name }).
    concat(PurInvoice.tag_counts.map {|t| t.name }).uniq
  end

  def loader_unloader_tags
    CashSale.loader_counts.map { |t| t.name }.
    concat(Invoice.loader_counts.map {|t| t.name }).
    concat(PurInvoice.loader_counts.map {|t| t.name }).
    concat(CashSale.unloader_counts.map {|t| t.name }).
    concat(PurInvoice.unloader_counts.map {|t| t.name }).
    concat(Invoice.unloader_counts.map {|t| t.name }).uniq
  end
end