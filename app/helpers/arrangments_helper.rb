module ArrangmentsHelper
  def assign_or_show_supplier order
    if order.assigned_purchase_order
      link_to "#{order.assigned_purchase_order.supplier_name1}"
    else
      link_to 'Assign Supplier'
    end
  end

  def assign_or_show_loader order
    if order.assigned_loading_order
      link_to "#{order.assigned_loading_order.transporter_name1}"
    else
      link_to 'Assign Loading'
    end
  end
end
