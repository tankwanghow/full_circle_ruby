# encoding: utf-8
class CashSalePdf < Prawn::Document
  include Prawn::Helper

  def initialize(cash_sales, view, static_content=false)
    super(page_size: [220.mm, 295.mm], margin: [0.mm, 0.mm, 0.mm, 0.mm], skip_page_creation: true)
    @view = view
    draw(cash_sales, static_content)
  end

  def draw(cash_sales, static_content)
    for p in cash_sales
      @cashsale = p
      @total_pages = 1
      @page_end_at = 32.mm
      @detail_height = 10.mm
      @detail_y_start_at = 208.mm
      start_new_cashsale_page
      draw_static_content if static_content
      fill_color "000077"
      font_size 10 do
        draw_header
        draw_detail
        draw_particular
      end
      draw_footer
      draw_cheque
      draw_page_number
      fill_color "000000"
    end
    self
  end

  def draw_static_content
    repeat(:all) do
      draw_text CompanyName, size: 18, style: :bold, at: [10.mm, 275.mm]
      draw_text @view.header_address_pdf(CompanyAddress), size: 9, at: [10.mm, 270.mm]
      draw_text @view.header_contact_pdf(CompanyAddress), size: 9, at: [10.mm, 266.mm]
      stroke_rounded_rectangle [10.mm, 260.mm], 200.mm, 32.mm, 3.mm
      stroke_rounded_rectangle [10.mm, 228.mm], 200.mm, 9.mm, 3.mm
      stroke_vertical_line 260.mm, 228.mm, at: 110.mm
      draw_text "CASH SALES", style: :bold, size: 12, at: [155.mm, 266.mm]
      draw_text "SOLD TO", size: 8, at: [12.mm, 255.mm]
      draw_text "DELIVERED TO", size: 8, at: [112.mm, 255.mm]
      stroke_vertical_line 228.mm, 219.mm, at: 55.mm
      stroke_vertical_line 228.mm, 219.mm, at: 110.mm
      stroke_vertical_line 228.mm, 219.mm, at: 165.mm
      draw_text "ACCOUNT ID", size: 8, at: [12.mm, 224.mm]
      draw_text "TERMS", size: 8, at: [57.mm, 224.mm]
      draw_text "DATE", size: 8, at: [112.mm, 224.mm]
      draw_text "SALES NO", size: 8, at: [167.mm, 224.mm]
      stroke_rounded_rectangle [10.mm, 219.mm], 200.mm, 174.mm, 3.mm
      stroke_horizontal_line 10.mm, 210.mm, at: 210.mm
      stroke_vertical_line 219.mm, 45.mm, at: 110.mm
      stroke_vertical_line 219.mm, 45.mm, at: 145.mm
      stroke_vertical_line 219.mm, 45.mm, at: 175.mm
      draw_text "PARTICULARS", size: 8, at: [53.mm, 213.5.mm]
      draw_text "QUANTITY", size: 8, at: [119.mm, 213.5.mm]
      draw_text "UNIT PRICE", size: 8, at: [152.mm, 213.5.mm]
      draw_text "AMOUNT", size: 8, at: [185.mm, 213.5.mm]
      draw_text "The above goods are delivered in good order and condition.", size: 8, at: [10.mm, 41.mm]
      draw_text "All Cheque should be made payable to the company & crossed 'A/C PAYEE ONLY'", size: 8, at: [10.mm, 37.mm]
      stroke_horizontal_line 110.mm, 150.mm, at: 23.mm
      stroke_horizontal_line 170.mm, 210.mm, at: 23.mm
      draw_text "CUSTOMER SIGNATURE", size: 8, at: [113.mm, 20.mm]
      draw_text "AUTHORIZED SIGNATURE", size: 8, at: [172.mm, 20.mm]
    end
  end

  #Dynamic Content
  def draw_header
    text_box @cashsale.customer.name1, at: [13.mm, 253.mm], size: 12, width: 100.mm, height: 20.mm, style: :bold
    if @cashsale.customer.mailing_address
      address_box(self, @cashsale.customer.mailing_address, [13.mm, 248.mm], width: 110.mm, height: 24.mm)
    end
    draw_text docnolize(@cashsale.customer.id), at: [30.mm, 220.5.mm], size: 10, style: :bold
    draw_text @view.term_string(0), at: [70.mm, 220.5.mm], style: :bold
    draw_text @cashsale.doc_date, at: [124.mm, 220.5.mm], style: :bold
    draw_text docnolize(@cashsale.id), at: [180.mm, 220.5.mm], style: :bold
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

    @cashsale.details.each do |t|

      bounding_box [12.mm, @detail_y], height: @detail_height, width: 100.mm do
        pack_qty = t.package_qty == 0 ? nil : @view.number_with_precision(t.package_qty, precision: 4, strip_insignificant_zeros: true)
        pack_name = t.try(:product_packaging).try(:pack_qty_name) ? "(#{t.product_packaging.pack_qty_name})" : nil
        pack_qty_name = [pack_qty, pack_name].flatten.join ''
        text_box [ pack_qty_name, t.product.name1, t.product.try(:name2), 
                   t.note].flatten.join(' '), overflow: :shrink_to_fit, valign: :center
      end

      bounding_box [110.mm, @detail_y], height: @detail_height, width: 35.mm do
        qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true)
        text_box [ qty, t.unit ].flatten.join(''), overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [145.mm, @detail_y], height: @detail_height, width: 30.mm do
        text_box @view.number_with_precision(t.unit_price, precision: 4), 
                 overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [175.mm, @detail_y], height: @detail_height, width: 37.mm do
        text_box t.total.to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_cashsale
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_particular
    @cashsale.particulars.each do |t|

      bounding_box [12.mm, @detail_y], height: @detail_height, width: 100.mm do
        text_box [ t.particular_type.name_nil_if_note, t.note].flatten.join(' '), overflow: :shrink_to_fit, valign: :center
      end

      bounding_box [110.mm, @detail_y], height: @detail_height, width: 35.mm do
        qty = @view.number_with_precision(t.quantity, precision: 4, strip_insignificant_zeros: true)
        text_box [ qty, t.unit ].flatten.join(''), overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [145.mm, @detail_y], height: @detail_height, width: 30.mm do
        text_box @view.number_with_precision(t.unit_price, precision: 4), 
                 overflow: :shrink_to_fit, valign: :center, align: :center
      end

      bounding_box [175.mm, @detail_y], height: @detail_height, width: 37.mm do
        text_box t.total.to_money.format, overflow: :shrink_to_fit, valign: :center, align: :center
      end

      @detail_y = @detail_y - @detail_height

      if @detail_y <= @page_end_at
        start_new_page_for_current_cashsale
        @detail_y = @detail_y_start_at
      end
    end
  end

  def draw_cheque
    text_box('Payment by Cheques :', at: [12.mm, @detail_y - 25.mm], size: 10, style: :bold) if @cashsale.cheques.count > 0
    @cashsale.cheques.each do |t|
      bounding_box [12.mm, @detail_y - 30.mm], height: 5.mm, width: 100.mm do
        text_box [ t.bank, t.chq_no, t.city, t.due_date, t.amount.to_money.format].join(' '), 
                 overflow: :shrink_to_fit, valign: :center, size: 10, align: :center
      end

      @detail_y = @detail_y - 5.mm

      if @detail_y <= @page_end_at
        start_new_page_for_current_cashsale
        @detail_y = @detail_y_start_at
      end
    end

  end

  def draw_footer
    group do
      bounding_box [12.mm, @detail_y], height: 25.mm, width: 100.mm do
        text_box "Note :\n" + @cashsale.note, overflow: :shrink_to_fit, valign: :center, size: 10
      end if !@cashsale.note.blank?
      line_width 1
      stroke_horizontal_line 175.mm, 210.mm, at: @detail_y 
      bounding_box [175.mm, @detail_y - 2.5.mm], height: 5.mm, width: 38.mm do
        text_box @cashsale.sales_amount.to_money.format, overflow: :shrink_to_fit,
                 align: :center, valign: :center, style: :bold, size: 11
      end
      line_width 2
      stroke_horizontal_line 175.mm, 210.mm, at: @detail_y - 10.mm
      line_width 1
    end
  end

  def start_new_page_for_current_cashsale
    @total_pages = @total_pages + 1
    start_new_page
    draw_header
  end

  def start_new_cashsale_page(options={})
    @total_pages = 1
    start_new_page
  end
end