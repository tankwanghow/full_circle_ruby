# encoding: utf-8
class InvoicePdf < Prawn::Document
  include Prawn::Helper

  def initialize(invoices, view, static_content=false)
    super(page_size: [220.mm, 295.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    draw(invoices, static_content)
  end

  def draw(invoices, static_content)
    for p in invoices
      @invoice = p
      @total_pages = 1
      @page_end_at = 32.mm
      @detail_height = 10.mm
      @detail_y_start_at = 205.mm
      start_new_invoice_page
      draw_static_content if static_content
      fill_color "000077"
      font_size 10 do
        draw_header
        draw_detail
        draw_particular
      end
      draw_footer
      draw_page_number
      fill_color "000000"
    end
    self
  end

  def draw_static_content
    repeat(:all) do
      draw_text CompanyName, size: 20, style: :bold, at: [9.mm, 270.mm]
      draw_text @view.header_address_pdf(CompanyAddress), size: 10, at: [9.mm, 266.mm]
      draw_text @view.header_contact_pdf(CompanyAddress), size: 10, at: [9.mm, 262.mm]
      stroke_rounded_rectangle [8.mm, 256.mm], 203.mm, 33.mm, 1.5.mm
      stroke_rounded_rectangle [8.mm, 223.mm], 203.mm, 9.mm, 1.5.mm
      stroke_vertical_line 256.mm, 223.mm, at: 104.mm
      draw_text "INVOICE", style: :bold, size: 12, at: [155.mm, 266.mm]
      draw_text "SOLD TO", size: 8, at: [11.mm, 252.mm]
      draw_text "DELIVERED TO", size: 8, at: [107.mm, 252.mm]
      stroke_vertical_line 223.mm, 214.mm, at: 58.mm
      stroke_vertical_line 223.mm, 214.mm, at: 109.mm
      stroke_vertical_line 223.mm, 214.mm, at: 160.mm
      draw_text "ACCOUNT ID", size: 8, at: [10.mm, 219.mm]
      draw_text "TERMS", size: 8, at: [59.mm, 219.mm]
      draw_text "DATE", size: 8, at: [110.mm, 219.mm]
      draw_text "INVOICE NO", size: 8, at: [162.mm, 219.mm]
      stroke_rounded_rectangle [8.mm, 214.mm], 203.mm, 168.mm, 1.5.mm
      stroke_horizontal_line 8.mm, 211.mm, at: 205.mm
      stroke_vertical_line 214.mm, 46.mm, at: 108.mm
      stroke_vertical_line 214.mm, 46.mm, at: 144.mm
      stroke_vertical_line 214.mm, 46.mm, at: 173.mm
      draw_text "PARTICULARS", size: 8, at: [53.mm, 208.5.mm]
      draw_text "QUANTITY", size: 8, at: [119.mm, 208.5.mm]
      draw_text "UNIT PRICE", size: 8, at: [150.mm, 208.5.mm]
      draw_text "AMOUNT", size: 8, at: [185.mm, 208.5.mm]
      draw_text "The above goods are delivered in good order and condition.", size: 8, at: [10.mm, 38.mm]
      draw_text "All Cheque should be made payable to the company & crossed 'A/C PAYEE ONLY'", size: 8, at: [10.mm, 33.mm]
      stroke_horizontal_line 110.mm, 150.mm, at: 23.mm
      stroke_horizontal_line 170.mm, 210.mm, at: 23.mm
      draw_text "CUSTOMER SIGNATURE", size: 8, at: [113.mm, 20.mm]
      draw_text "AUTHORIZED SIGNATURE", size: 8, at: [172.mm, 20.mm]
    end
  end

  #Dynamic Content
  def draw_header
    text_box @invoice.customer.name1, at: [13.mm, 250.mm], size: 12, width: 100.mm, height: 20.mm, style: :bold
    if @invoice.customer.mailing_address
      address_box(self, @invoice.customer.mailing_address, [13.mm, 245.mm], width: 110.mm, height: 24.mm)
    end
    draw_text @view.docnolize(@invoice.customer.id), at: [30.mm, 216.mm], size: 10
    draw_text @view.term_string(@invoice.credit_terms), at: [70.mm, 216.mm], style: :bold
    draw_text @invoice.doc_date, at: [124.mm, 216.mm], style: :bold
    draw_text @view.docnolize(@invoice.id), at: [180.mm, 216.mm], style: :bold
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

      bounding_box [12.mm, @detail_y], height: @detail_height, width: 100.mm do
        pack_qty = t.package_qty == 0 ? nil : @view.number_with_precision(t.package_qty, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
        pack_name = t.try(:product_packaging).try(:pack_qty_name) ? "(#{t.product_packaging.pack_qty_name})" : nil
        pack_qty_name = [pack_qty, pack_name].flatten.join ''
        text_box [ pack_qty_name, t.product.name1, t.product.try(:name2), 
                   t.note].flatten.join(' '), overflow: :shrink_to_fit, valign: :center
      end

      bounding_box [110.mm, @detail_y], height: @detail_height, width: 35.mm do
        qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
        text_box [ qty, t.unit ].flatten.join(''), overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [145.mm, @detail_y], height: @detail_height, width: 30.mm do
        text_box @view.number_with_precision(t.unit_price, precision: 4, delimiter: ','), 
                 overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [175.mm, @detail_y], height: @detail_height, width: 37.mm do
        text_box t.total.to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_invoice
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_particular

    @invoice.particulars.each do |t|

      bounding_box [12.mm, @detail_y], height: @detail_height, width: 100.mm do
        text_box [ t.particular_type.name_nil_if_note, t.note].flatten.join(' '), overflow: :shrink_to_fit, valign: :center
      end

      bounding_box [110.mm, @detail_y], height: @detail_height, width: 35.mm do
        qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
        text_box [ qty, t.unit ].flatten.join(''), overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [145.mm, @detail_y], height: @detail_height, width: 30.mm do
        text_box @view.number_with_precision(t.unit_price, precision: 4, delimiter: ','), 
                 overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [175.mm, @detail_y], height: @detail_height, width: 37.mm do
        text_box t.total.to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_invoice
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    group do
      bounding_box [12.mm, @detail_y], height: 25.mm, width: 100.mm do
        text_box "Note :\n" + @invoice.note, overflow: :shrink_to_fit, valign: :center, size: 10
      end if !@invoice.note.blank?
      line_width 1
      stroke_horizontal_line 175.mm, 210.mm, at: @detail_y 
      bounding_box [175.mm, @detail_y - 2.5.mm], height: 5.mm, width: 38.mm do
        text_box @invoice.invoice_amount.to_money.format, overflow: :shrink_to_fit,
                 align: :center, valign: :center, style: :bold, size: 11
      end
      line_width 2
      stroke_horizontal_line 175.mm, 210.mm, at: @detail_y - 10.mm
      line_width 1
    end
  end

  def start_new_page_for_current_invoice
    @total_pages = @total_pages + 1
    start_new_page
    draw_header
  end

  def start_new_invoice_page(options={})
    @total_pages = 1
    start_new_page
  end
end