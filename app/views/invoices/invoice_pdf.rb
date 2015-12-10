# encoding: utf-8
class InvoicePdf < Prawn::Document
  include Prawn::Helper

  def initialize(invoices, view, static_content=false)
    super(page_size: [210.mm, 297.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    @static_content = static_content
    draw invoices
  end

  def draw invoices
    for p in invoices
      @invoice = p
      @total_pages = 1
      @page_end_at = 60.mm
      @detail_height = 10.mm
      @detail_y_start_at = 215.mm
      start_new_invoice_page
      fill_color "000077"
      font_size 10 do
        draw_header
        draw_detail
        draw_particular
        draw_footer
      end
      draw_page_number
      fill_color "000000"
    end
    self
  end

  def draw_static_content
    draw_text CompanyName, size: 18, style: :bold, at: [10.mm, 275.mm]
    draw_text @view.header_address_pdf(CompanyAddress), size: 10, at: [10.mm, 270.mm]
    draw_text @view.header_contact_pdf(CompanyAddress), size: 10, at: [10.mm, 265.mm]
    draw_text "The above goods are delivered in good order and condition.", size: 8, at: [10.mm, 33.mm]
    draw_text "All Cheque should be made payable to the company & crossed 'A/C PAYEE ONLY'", size: 8, at: [10.mm, 30.mm]
    stroke_horizontal_line 100.mm, 150.mm, at: 13.mm
    stroke_horizontal_line 160.mm, 200.mm, at: 13.mm
    draw_text "RECEIVER SIGNATURE", size: 8, at: [110.mm, 9.mm]
    draw_text "AUTHORIZED SIGNATURE", size: 8, at: [162.mm, 9.mm]
    stroke_horizontal_line 10.mm, 200.mm, at: 260.mm
    stroke_horizontal_line 10.mm, 200.mm, at: 37.mm
  end

  #Dynamic Content
  def draw_header
    draw_text "TAX INVOICE", style: :bold, size: 12, at: [155.mm, 273.mm]
    draw_text "INV NO :", size: 16, at: [150.mm, 265.mm]
    draw_text @view.docnolize(@invoice.id), at: [174.mm, 265.mm], size: 16, style: :bold
    draw_text "TO", size: 10, at: [12.mm, 255.mm]
    text_box @invoice.customer.name1, at: [13.mm, 253.mm], size: 11, width: 120.mm, height: 20.mm, style: :bold
    if @invoice.customer.mailing_address
      address_box(self, @invoice.customer.mailing_address, [13.mm, 248.mm], width: 110.mm, height: 24.mm)
    end
    draw_text "DATE :", size: 10, at: [130.mm, 255.mm]
    draw_text @invoice.doc_date, at: [155.mm, 255.mm], style: :bold, size: 10

    draw_text "ACCOUNT ID :", size: 10, at: [130.mm, 250.mm]
    draw_text @view.docnolize(@invoice.customer.id), at: [155.mm, 250.mm], style: :bold, size: 10

    stroke_horizontal_line 10.mm, 200.mm, at: 226.mm

    bounding_box [10.mm, 225.mm], height: 9.mm, width: 61.mm do
      text_box 'Particulars', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [70.mm, 225.mm], height: 9.mm, width: 20.mm do
      text_box 'Quantity', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [90.mm, 225.mm], height: 9.mm, width: 16.mm do
      text_box 'Price', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [106.mm, 225.mm], height: 9.mm, width: 15.mm do
      text_box 'Disc.', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [121.mm, 225.mm], height: 9.mm, width: 23.mm do
      text_box 'Amount', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [144.mm, 225.mm], height: 9.mm, width: 15.mm do
      text_box 'GST%', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [159.mm, 225.mm], height: 9.mm, width: 18.mm do
      text_box 'GST', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    bounding_box [177.mm, 225.mm], height: 9.mm, width: 23.mm do
      text_box 'Total', overflow: :wrap, valign: :center, align: :center, style: :bold
    end

    stroke_horizontal_line 10.mm, 200.mm, at: 216.mm

    if @invoice.loader_list.count > 0
      draw_text "LOADER :", size: 8, at: [10.mm, 26.mm]
      draw_text @invoice.loader_list.join(', '), at: [30.mm, 26.mm], size: 8
    end

    if @invoice.unloader_list.count > 0
      draw_text "UNLOADER :", size: 8, at: [10.mm, 23.mm]
      draw_text @invoice.unloader_list.join(', '), at: [30.mm, 23.mm], size: 8
    end

    draw_text "ISSUED BY :", size: 8, at: [10.mm, 20.mm]
    draw_text @invoice.audits.last.user.name, at: [30.mm, 20.mm], size: 8

  end

  def draw_page_number
    i = 0
    ((page_count - @total_pages + 1)..page_count).step(1) do |p|
      go_to_page p
      bounding_box [bounds.right - 30.mm, bounds.top - 8.mm], width: 30.mm, height: 5.mm do
        text "Page #{i+=1} of #{@total_pages}", size: 9
      end
    end
  end

  def draw_detail
    @detail_y = @detail_y_start_at

    @invoice.details.each do |t|

      draw_product_line t, @detail_y, @detail_height

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_invoice
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_product_line detail, y, h
    bounding_box [10.mm, y], height: h, width: 61.mm do
      pack_qty = detail.package_qty == 0 ? nil : @view.number_with_precision(detail.package_qty, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
      pack_name = detail.try(:product_packaging).try(:pack_qty_name) ? "(#{detail.product_packaging.pack_qty_name})" : nil
      pack_qty_name = [pack_qty, pack_name].flatten.join ' '
      text_box [ pack_qty_name, detail.product.name1, detail.product.try(:name2),
       detail.note].flatten.join(' '), overflow: :shrink_to_fit, valign: :center
     end

    bounding_box [70.mm, y], height: h, width: 20.mm do
      qty = @view.number_with_precision(detail.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
      text_box [ qty, detail.unit ].flatten.join(' '), overflow: :shrink_to_fit, valign: :center, align: :center
    end

    bounding_box [90.mm, y], height: h, width: 16.mm do
      text_box @view.number_with_precision(detail.unit_price, precision: 4, delimiter: ','),
      overflow: :shrink_to_fit, valign: :center, align: :center
    end

    bounding_box [106.mm, y], height: h, width: 15.mm do
      text_box @view.number_with_precision(detail.discount, precision: 2, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center
    end

    bounding_box [121.mm, y], height: h, width: 23.mm do
      text_box @view.number_with_precision(detail.goods_total - detail.discount, precision: 2, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center
    end

    if detail.tax_code
      bounding_box [144.mm, y], height: h, width: 15.mm do
        text_box "#{detail.tax_code.code}-#{detail.tax_code.rate}%", overflow: :shrink_to_fit, valign: :center, align: :center, size: 9
      end

      bounding_box [159.mm, y], height: h, width: 18.mm do
          text_box @view.number_with_precision(detail.gst, precision: 2, delimiter: ','),
                 overflow: :shrink_to_fit, valign: :center, align: :center
      end
    end

    bounding_box [177.mm, y], height: h, width: 23.mm do
        text_box @view.number_with_precision(detail.in_gst_total, precision: 2, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center
    end
  end

  def draw_particular
    @invoice.particulars.each do |t|

      bounding_box [10.mm, @detail_y], height: @detail_height, width: 60.mm do
        text_box [ t.particular_type.name_nil_if_note, t.note].flatten.join(' '), overflow: :shrink_to_fit, valign: :center
      end

      bounding_box [70.mm, @detail_y], height: @detail_height, width: 20.mm do
        qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
        text_box [ qty, t.unit ].flatten.join(' '), overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [90.mm, @detail_y], height: @detail_height, width: 16.mm do
        text_box @view.number_with_precision(t.unit_price, precision: 4, delimiter: ','),
                 overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [121.mm, @detail_y], height: @detail_height, width: 23.mm do
        text_box @view.number_with_precision(t.ex_gst_total, precision: 2, delimiter: ','),
                 overflow: :shrink_to_fit, valign: :center, align: :center
      end

      if t.tax_code
        bounding_box [144.mm, @detail_y], height: @detail_height, width: 15.mm do
          text_box "#{t.tax_code.code}-#{t.tax_code.rate}%", overflow: :shrink_to_fit, valign: :center, align: :center, size: 9
        end

        bounding_box [159.mm, @detail_y], height: @detail_height, width: 18.mm do
          text_box @view.number_with_precision(t.gst, precision: 2, delimiter: ','),
                 overflow: :shrink_to_fit, valign: :center, align: :center
        end
      end

      bounding_box [177.mm, @detail_y], height: @detail_height, width: 23.mm do
        text_box @view.number_with_precision(t.in_gst_total, precision: 2, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_invoice
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    bounding_box [10.mm, @detail_y - 10.mm], height: 20.mm, width: 95.mm do
        text_box "Note :-\n" + @invoice.note, overflow: :shrink_to_fit, valign: :top, style: :bold
    end if !@invoice.note.blank?

    stroke_horizontal_line 10.mm, 200.mm, at: @detail_y - 1.mm
    bounding_box [90.mm, @detail_y], height: 9.mm, width: 16.mm do
      text_box 'Total', overflow: :shrink_to_fit, valign: :center, align: :center, style: :bold
    end

    bounding_box [106.mm, @detail_y], height: 9.mm, width: 15.mm do
      text_box @view.number_with_precision(@invoice.discount_amount, precision: 2, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center, style: :bold
    end

    bounding_box [121.mm, @detail_y], height: 9.mm, width: 23.mm do
      text_box @view.number_with_precision(@invoice.goods_amount, precision: 2, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center, style: :bold
    end

    bounding_box [159.mm, @detail_y], height: 9.mm, width: 18.mm do
      text_box @view.number_with_precision(@invoice.gst_amount, precision: 2, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center, style: :bold
    end

    bounding_box [177.mm, @detail_y], height: 9.mm, width: 23.mm do
      text_box @view.number_with_precision(@invoice.invoice_amount, precision: 2, delimiter: ','),
               overflow: :shrink_to_fit, valign: :center, align: :center, style: :bold
    end
    stroke_horizontal_line 10.mm, 200.mm, at: @detail_y - 8.mm

  end

  def start_new_page_for_current_invoice
    @total_pages = @total_pages + 1
    start_new_page
    draw_static_content if @static_content
    draw_header
  end

  def start_new_invoice_page(options={})
    @total_pages = 1
    start_new_page
    draw_static_content if @static_content
  end
end