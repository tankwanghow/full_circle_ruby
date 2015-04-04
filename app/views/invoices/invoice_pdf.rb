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
      @page_end_at = 64.mm
      @detail_height = 6.mm
      @detail_y_start_at = 200.mm
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
      draw_text CompanyName, size: 20, style: :bold, at: [9.mm, 272.mm]
      draw_text @view.header_address_pdf(CompanyAddress), size: 10, at: [9.mm, 266.mm]
      draw_text @view.header_contact_pdf(CompanyAddress), size: 10, at: [9.mm, 261.mm]
      stroke_rounded_rectangle [8.mm, 253.mm], 203.mm, 32.mm, 1.5.mm
      stroke_rounded_rectangle [8.mm, 221.mm], 203.mm, 9.mm, 1.5.mm
      stroke_vertical_line 253.mm, 221.mm, at: 104.mm
      draw_text "TAX INVOICE", style: :bold, size: 12, at: [180.mm, 257.mm]
      draw_text "SOLD TO", size: 8, at: [11.mm, 249.mm]
      draw_text "DELIVERED TO", size: 8, at: [107.mm, 249.mm]
      stroke_vertical_line 221.mm, 212.mm, at: 58.mm
      stroke_vertical_line 221.mm, 212.mm, at: 109.mm
      stroke_vertical_line 221.mm, 212.mm, at: 160.mm
      draw_text "ACCOUNT ID", size: 8, at: [10.mm, 218.mm]
      draw_text "TERMS", size: 8, at: [59.mm, 218.mm]
      draw_text "DATE", size: 8, at: [110.mm, 218.mm]
      draw_text "INVOICE NO", size: 8, at: [162.mm, 218.mm]
      stroke_rounded_rectangle [8.mm, 212.mm], 203.mm, 167.mm, 1.5.mm
      stroke_horizontal_line 8.mm, 211.mm, at: 205.mm
      stroke_vertical_line 212.mm, 45.mm, at: 109.mm
      stroke_vertical_line 212.mm, 45.mm, at: 145.mm
      stroke_vertical_line 212.mm, 45.mm, at: 175.mm
      draw_text "PARTICULARS", size: 8, at: [53.mm, 208.mm]
      draw_text "QUANTITY", size: 8, at: [119.mm, 208.mm]
      draw_text "UNIT PRICE", size: 8, at: [150.mm, 208.mm]
      draw_text "AMOUNT", size: 8, at: [185.mm, 208.mm]
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
    draw_text "TAX", style: :bold, size: 12, at: [170.mm, 257.mm]
    draw_text "GST No. #{CompanyAddress.gst_no}", style: :bold, size: 12, at: [60.mm, 257.mm]
    text_box @invoice.customer.name1, at: [13.mm, 245.mm], size: 12, width: 100.mm, height: 20.mm, style: :bold
    if @invoice.customer.mailing_address
      address_box(self, @invoice.customer.mailing_address, [13.mm, 240.mm], width: 110.mm, height: 24.mm)
    end
    draw_text @view.docnolize(@invoice.customer.id), at: [30.mm, 215.mm], size: 10
    draw_text @view.term_string(@invoice.credit_terms), at: [70.mm, 215.mm], style: :bold
    draw_text @invoice.doc_date, at: [124.mm, 215.mm], style: :bold
    draw_text @view.docnolize(@invoice.id), at: [180.mm, 215.mm], style: :bold
  end

  def draw_page_number
    i = 0
    ((page_count - @total_pages + 1)..page_count).step(1) do |p|
      go_to_page p
      bounding_box [bounds.right - 30.mm, bounds.top - 10.mm], width: 30.mm, height: 5.mm do
        text "Page #{i+=1} of #{@total_pages}", size: 9
      end
    end
  end

  def draw_detail
    @detail_y = @detail_y_start_at

    @invoice.details.each do |t|

      draw_product_line t, @detail_y, @detail_height
      draw_gst_discount_line t

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_cashsale
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_gst_discount_line detail
    @detail_y = @detail_y - 4.5.mm if detail.gst != 0 || detail.discount != 0
    bounding_box [15.mm, @detail_y + 0.5.mm], height: @detail_height, width: 100.mm do
      text_box "- GST #{detail.tax_code.code} #{detail.tax_code.rate}% X #{@view.number_with_precision(detail.ex_gst_total, precision: 2, delimiter: ',')} = #{@view.number_with_precision(detail.gst, precision: 2, delimiter: ',')}", overflow: :shrink_to_fit, valign: :center, size: 9
     end if detail.gst != 0

    if detail.discount != 0
      bounding_box [145.mm, @detail_y], height: @detail_height, width: 30.mm do
        text_box 'Discount', overflow: :shrink_to_fit, valign: :center, align: :center
      end
      bounding_box [176.mm, @detail_y], height: @detail_height, width: 33.mm do
        text_box @view.number_with_precision(detail.discount, precision: 2, delimiter: ','),
                 overflow: :shrink_to_fit, valign: :center, align: :right
      end
    end
  end

  def draw_product_line detail, y, h
    bounding_box [12.mm, y], height: h, width: 100.mm do
      pack_qty = detail.package_qty == 0 ? nil : @view.number_with_precision(detail.package_qty, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
      pack_name = detail.try(:product_packaging).try(:pack_qty_name) ? "(#{detail.product_packaging.pack_qty_name})" : nil
      pack_qty_name = [pack_qty, pack_name].flatten.join ''
      text_box [ pack_qty_name, detail.product.name1, detail.product.try(:name2), 
       detail.note].flatten.join(' '), overflow: :shrink_to_fit, valign: :center
     end

     bounding_box [110.mm, y], height: h, width: 35.mm do
      qty = @view.number_with_precision(detail.quantity, precision: 4, strip_insignificant_zeros: true, delimiter: ',')
      text_box [ qty, detail.unit ].flatten.join(''), overflow: :shrink_to_fit, valign: :center, align: :center
    end

    bounding_box [145.mm, y], height: h, width: 30.mm do
      text_box @view.number_with_precision(detail.unit_price, precision: 4, delimiter: ','), 
      overflow: :shrink_to_fit, valign: :center, align: :center
    end

    bounding_box [174.mm, y], height: h, width: 37.mm do
      text_box @view.number_with_precision(detail.goods_total, precision: 2, delimiter: ','), 
               overflow: :shrink_to_fit, valign: :center, align: :center
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

      bounding_box [175.mm, @detail_y], height: @detail_height, width: 34.mm do
        text_box @view.number_with_precision(t.ex_gst_total, precision: 2, delimiter: ','),
                 overflow: :shrink_to_fit, valign: :center, align: :right
      end
      if t.gst != 0
        @detail_y = @detail_y - 4.5.mm
        bounding_box [15.mm, @detail_y + 0.5.mm], height: @detail_height, width: 100.mm do
          text_box "- GST #{t.tax_code.code} #{t.tax_code.rate}% X #{@view.number_with_precision(t.ex_gst_total, precision: 2, delimiter: ',')} = #{@view.number_with_precision(t.gst, precision: 2, delimiter: ',')}", overflow: :shrink_to_fit, valign: :center, size: 9
        end
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_cashsale
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_footer
    local_y = @detail_y
    group do
      font_size 10 do
        bounding_box [12.mm, local_y], height: 25.mm, width: 98.mm do
          text_box "Note :\n" + @invoice.note, overflow: :shrink_to_fit, valign: :center, style: :bold
        end if !@invoice.note.blank?

        stroke_horizontal_line 8.mm, 211.mm, at: local_y
        
        local_y = local_y - 1.mm 
        bounding_box [144.mm, local_y], height: 6.mm, width: 30.mm do
          text_box "Sales Excl. GST", valign: :center, style: :bold, align: :center
        end
        bounding_box [174.mm, local_y], height: 6.mm, width: 34.mm do
          text_box (@invoice.goods_amount + @invoice.particulars_ex_gst_amount).to_money.format, overflow: :shrink_to_fit,
                   align: :center, valign: :center, style: :bold, align: :right
        end

        if @invoice.discount_amount != 0
          local_y = local_y - 6.mm
          stroke_horizontal_line 145.mm, 211.mm, at: local_y
          bounding_box [145.mm, local_y - 0.5.mm], height: 6.mm, width: 30.mm do
            text_box "Discount", valign: :center, style: :bold, align: :center
          end
          bounding_box [174.mm, local_y - 0.5.mm], height: 6.mm, width: 34.mm do
            text_box @invoice.discount_amount.to_money.format, overflow: :shrink_to_fit,
            valign: :center, style: :bold, align: :right
          end
        end
        
        local_y = local_y - 6.mm
        bounding_box [145.mm, local_y - 0.5.mm], height: 6.mm, width: 30.mm do
          text_box "GST Payable", valign: :center, style: :bold, align: :center
        end
        stroke_horizontal_line 145.mm, 211.mm, at: local_y
        bounding_box [174.mm, local_y - 0.5.mm], height: 6.mm, width: 34.mm do
          text_box @invoice.gst_amount.to_money.format, overflow: :shrink_to_fit,
                   valign: :center, style: :bold, align: :right
        end

        local_y = local_y - 6.mm
        stroke_horizontal_line 145.mm, 211.mm, at: local_y
        bounding_box [145.mm, local_y - 0.5.mm], height: 6.mm, width: 30.mm do
          text_box "Sales Incl. GST", valign: :center, style: :bold, align: :center
        end
        bounding_box [174.mm, local_y - 0.5.mm], height: 6.mm, width: 34.mm do
          text_box @invoice.invoice_amount.to_money.format, overflow: :shrink_to_fit,
                   valign: :center, style: :bold, align: :right
        end
        bounding_box [109 .mm, @detail_y], height: @detail_y - local_y + 7.mm, width: 35.mm do
          text_box "TOTAL", style: :bold, size: 14, align: :center, valign: :center
        end
        stroke_horizontal_line 109.mm, 211.mm, at: local_y - 6.mm
      end
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